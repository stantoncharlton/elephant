class DrillingLogsController < ApplicationController
    before_filter :signed_in_user, only: [:index, :show]

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
        @bhas = Bha.where(:company_id => current_user.company_id).where(:job_id => @drilling_log.job_id).order("bhas.name ASC")

        if params[:report].present? && params[:report] == "true" && params[:report_name].present?

            report_exists = false
            report_name = params[:report_name]
            case report_name
                when "daily_report"
                    report_exists = true
            end

            if report_exists

                report = ODFReport::Report.new(Rails.root.join("app/assets/templates/#{report_name}.odt")) do |r|
                    r.add_field "ROP", "3.34"
                end
                file = "#{Rails.root}/tmp/#{SecureRandom.hex}_daily_report.odt"
                report.generate(file)

                url = "docs/#{SecureRandom.hex}/#{report_name}.odt"
                s3 = AWS::S3.new
                s3.buckets['elephant-docs'].objects[url].write(File.read(file))

                Common::Product.setBaseProductUri("http://api.saaspose.com/v1.0")
                Common::SaasposeApp.new(ENV["SAASPOSE_APPSID"], ENV["SAASPOSE_APPKEY"])

                oldFile = "http://api.saaspose.com/v1.0/words/#{File.basename(url)}?format=pdf&storage=elephant&folder=elephant-docs/#{File.dirname(url)}"
                newFile = "http://api.saaspose.com/v1.0/storage/file/elephant-docs/#{File.dirname(url)}/#{File.basename(url, '.*')}.pdf?storage=elephant"

                RestClient.put Common::Utils.sign(newFile), open(Common::Utils.sign(oldFile)), {:accept => :json}

                pdf = s3.buckets['elephant-docs'].objects["#{File.dirname(url)}/#{File.basename(url, '.*')}.pdf"]
                full_url = pdf.url_for(:get, {
                        expires: 10.minutes,
                        response_content_disposition: 'attachment;'
                }).to_s

                redirect_to full_url
            end
            #send_data excel.to_stream.read, :filename => 'jobs.xlsx', :type => "application/vnd.openxmlformates-officedocument.spreadsheetml.sheet"
            return
        end
    end


end
