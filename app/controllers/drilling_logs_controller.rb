class DrillingLogsController < ApplicationController
    before_filter :signed_in_user, only: [:index, :create]

    def index
        @document = Document.find(params[:document])
        not_found unless !@document.nil?
        not_found unless @document.company == current_user.company && @document.document_type == Document::DRILLING_LOG

        @drilling_logs = DrillingLog.where(:company_id => current_user.company_id).where(:document_id => @document.id).order("entry_at ASC")

        @bhas = Bha.where(:company_id => current_user.company_id).where(:job_id => @document.job_id)
    end

    def create
        document_id = params[:drilling_log][:document_id]
        params[:drilling_log].delete(:document_id)

        bha_id = params[:drilling_log][:bha_id]
        params[:drilling_log].delete(:bha_id)

        @document = Document.find(document_id)
        not_found unless @document.company == current_user.company && @document.document_type == Document::DRILLING_LOG

        override_date = nil
        if params[:drilling_log][:override_date] == "1"
            override_date = Time.strptime("#{params[:date]} #{params[:hour]}:#{params[:minute]}:00 #{params[:meridian]}", '%m/%d/%Y %I:%M:%S %p').in_time_zone(Time.zone)
        end

        params[:drilling_log].delete(:override_date)

        @drilling_log = DrillingLog.new(params[:drilling_log])
        @drilling_log.document = @document
        not_found unless @drilling_log.document.company == current_user.company
        @drilling_log.company = current_user.company
        @drilling_log.job = @drilling_log.document.job
        @drilling_log.user = current_user
        @drilling_log.user_name = current_user.name
        @drilling_log.bha = Bha.find(bha_id)

        if override_date.nil?
            @drilling_log.entry_at = Time.now
        else
            @drilling_log.entry_at = override_date
        end

        @last_entry = DrillingLog.where(:company_id => current_user.company_id).where(:job_id => @document.job_id).last

        @drilling_log.save

        if @last_entry.nil?
            @last_entry = @drilling_log
        end
    end
end
