class DrillingLogsController < ApplicationController
    before_filter :signed_in_user, only: [:index]

    skip_before_filter :verify_traffic, only: [:show]
    skip_before_filter :session_expiry, only: [:show]
    skip_before_filter :update_session_expiration, only: [:show]

    before_filter :check_user_or_access_code, only: [:show]

    def check_user_or_access_code
        if !signed_in?
            share = cookies[:share]
            access_code = cookies[:access_code]
            email = cookies[:email]

            if !share.blank? && !access_code.blank? && !email.blank?
                @document_share = DocumentShare.find_by_id(share)
                not_found unless @document_share.present? &&
                        @document_share.access_code == access_code &&
                        @document_share.email == email

                @drilling_log = DrillingLog.find_by_id(params[:id])
                not_found unless @drilling_log.present? && @drilling_log.document == @document_share.document
            else
                signed_in_user
            end
        else
            verify_traffic
            session_expiry unless !signed_in?
            update_session_expiration unless !signed_in?
            signed_in_user unless !signed_in?
        end
    end

    include DrillingLogsHelper

    def index
        if params[:document].present?
            @document = Document.find_by_id(params[:document])
            @drilling_log = DrillingLog.find_by_document_id(@document.id)
            if @drilling_log.nil?
                if @document.document_type == Document::DRILLING_LOG
                    @drilling_log = DrillingLog.new
                    @drilling_log.company = current_user.company
                    @drilling_log.job = @document.job
                    @drilling_log.document = @document
                    @drilling_log.save
                    redirect_to @drilling_log
                end
            else
                redirect_to @drilling_log
            end
        end
    end

    def show
        @drilling_log = DrillingLog.find(params[:id])
        not_found unless @drilling_log.present?
        @bhas = Bha.joins(document: {job: :well}).where("bhas.master_bha_id IS NULL").where("jobs.well_id = ?", @drilling_log.job.well_id).order("bhas.name ASC")


        respond_to do |format|
            format.html {

            }
            format.js {
                if params[:report].present? && params[:report] == "true" && params[:report_name].present?
                    create_report
                end

            }
            format.xlsx {
                excel = drilling_log_to_excel @drilling_log
                send_data excel.to_stream.read, :filename => "Daily Activity.xlsx", :type => "application/vnd.openxmlformates-officedocument.spreadsheetml.sheet"
            }
        end

    end


    private

    def create_report
        report_exists = false
        @report_name = params[:report_name]
        case @report_name
            when "drilling_report"
                report_exists = true
            when "bha_report"
                report_exists = true
            when "run_report"
                report_exists = true
            when "daily_activity"
                report_exists = true
            when "survey"
                report_exists = true
            when "railroad"
                report_exists = true
            when "railroad_certification"
                report_exists = true
        end

        if report_exists

            report = ODFReport::Report.new(Rails.root.join("app/assets/templates/#{@report_name}.odt")) do |r|
                case @report_name
                    when "drilling_report"
                        type = params[:type].to_i
                        entries = @drilling_log.drilling_log_entries.includes(:bha).to_a
                        dates = entries.group_by { |item| item.entry_at.to_date }
                        dates.each_with_index do |d, index|
                            if type == index + 1
                                entries = d[1]
                            end
                        end

                        fill_drilling_report @drilling_log.job, entries, r, entries.any? ? entries.first.entry_at : Time.now, entries.any? ? entries.last.entry_at : Time.now
                    when "run_report"
                        index = params[:type].to_i
                        if index > 0
                            runs = @drilling_log.get_runs
                            entries = runs[index - 1]
                        else
                            entries = @drilling_log.drilling_log_entries
                        end

                        fill_run_report @drilling_log.job, entries, r, entries.any? ? entries.first.entry_at : Time.now, entries.any? ? entries.last.entry_at : Time.now, index
                    when "bha_report"
                        bha_id = params[:type].to_i
                        if bha_id > 0
                            bha = Bha.find_by_id(bha_id)
                            entries = @drilling_log.drilling_log_entries.where("drilling_log_entries.bha_id = ?", bha.id).to_a
                        else
                            entries = @drilling_log.drilling_log_entries
                            bha = entries.last.bha
                        end

                        fill_bha_report @drilling_log.job, entries, r, entries.any? ? entries.first.entry_at : Time.now, entries.any? ? entries.last.entry_at : Time.now, bha, 1
                    when "daily_activity"
                        type = params[:type].to_i
                        entries = @drilling_log.drilling_log_entries.includes(:bha).to_a
                        dates = entries.group_by { |item| item.entry_at.to_date }
                        dates.each_with_index do |d, index|
                            if type == index + 1
                                entries = d[1]
                            end
                        end

                        fill_log @drilling_log.job, entries, r, entries.any? ? entries.first.entry_at : Time.now, entries.any? ? entries.last.entry_at : Time.now
                    when "survey"
                        @active_well_plan = Survey.includes(document: {job: :well}).where(:plan => true).where("wells.id = ?", @drilling_log.job.well_id).first
                        @survey = Survey.includes(document: {job: :well}).where(:plan => false).where("wells.id = ?", @drilling_log.job.well_id).first
                        calculated_points_survey = @survey.calculated_points(@active_well_plan.vertical_section_azimuth)
                        fill_survey @drilling_log.job, calculated_points_survey, r
                    when "railroad"
                        @active_well_plan = Survey.includes(document: {job: :well}).where(:plan => true).where("wells.id = ?", @drilling_log.job.well_id).first
                        @survey = Survey.includes(document: {job: :well}).where(:plan => false).where("wells.id = ?", @drilling_log.job.well_id).first
                        calculated_points_survey = @survey.calculated_points(@active_well_plan.vertical_section_azimuth)
                        fill_railroad @drilling_log.job, @active_well_plan, calculated_points_survey, r
                    when "railroad_certification"
                        @active_well_plan = Survey.includes(document: {job: :well}).where(:plan => true).where("wells.id = ?", @drilling_log.job.well_id).first
                        @survey = Survey.includes(document: {job: :well}).where(:plan => false).where("wells.id = ?", @drilling_log.job.well_id).first
                        calculated_points_survey = @survey.calculated_points(@active_well_plan.vertical_section_azimuth)
                        fill_railroad_certification @drilling_log.job, @drilling_log, @active_well_plan, @survey, calculated_points_survey, r
                end
            end
            file = "#{Rails.root}/tmp/#{SecureRandom.hex}_#{@report_name}.odt"
            report.generate(file)

            url = "docs/#{SecureRandom.hex}/#{@report_name}.odt"
            s3 = AWS::S3.new
            s3.buckets['elephant-docs'].objects[url].write(File.read(file))

            Common::Product.setBaseProductUri("http://api.saaspose.com/v1.0")
            Common::SaasposeApp.new(ENV["SAASPOSE_APPSID"], ENV["SAASPOSE_APPKEY"])

            oldFile = "http://api.saaspose.com/v1.0/words/#{File.basename(url)}?format=pdf&storage=elephant&folder=elephant-docs/#{File.dirname(url)}"
            newFile = "http://api.saaspose.com/v1.0/storage/file/elephant-docs/#{File.dirname(url)}/#{File.basename(url, '.*')}.pdf?storage=elephant"

            RestClient.put Common::Utils.sign(newFile), open(Common::Utils.sign(oldFile)), {:accept => :json}

            pdf = s3.buckets['elephant-docs'].objects["#{File.dirname(url)}/#{File.basename(url, '.*')}.pdf"]
            @full_url = pdf.url_for(:get, {
                    expires: 1.day,
                    response_content_disposition: 'attachment;'
            }).to_s

            File.delete(file) if File.exist?(file)

            #redirect_to full_url
        end
        #send_data excel.to_stream.read, :filename => 'jobs.xlsx', :type => "application/vnd.openxmlformates-officedocument.spreadsheetml.sheet"
        #return
    end

end
