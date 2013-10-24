class DrillingLogEntriesController < ApplicationController
    before_filter :signed_in_user, only: [:index, :create]

    def index
        @document = Document.find(params[:document])
        not_found unless !@document.nil?
        not_found unless @document.company == current_user.company && @document.document_type == Document::DRILLING_LOG

        @drilling_log_entries = DrillingLogEntry.where(:company_id => current_user.company_id).where(:document_id => @document.id).order("entry_at ASC")

        @bhas = Bha.where(:company_id => current_user.company_id).where(:job_id => @document.job_id)
    end

    def create
        document_id = params[:drilling_log_entry][:document_id]
        params[:drilling_log_entry].delete(:document_id)

        bha_id = params[:drilling_log_entry][:bha_id]
        params[:drilling_log_entry].delete(:bha_id)

        @document = Document.find(document_id)
        not_found unless @document.company == current_user.company && @document.document_type == Document::DRILLING_LOG

        override_date = nil
        if params[:drilling_log_entry][:override_date] == "1"
            override_date = Time.strptime("#{params[:date]} #{params[:hour]}:#{params[:minute]}:00 #{params[:meridian]}", '%m/%d/%Y %I:%M:%S %p').in_time_zone(Time.zone)
        end

        params[:drilling_log_entry].delete(:override_date)

        @drilling_log_entry = DrillingLogEntry.new(params[:drilling_log_entry])
        @drilling_log_entry.document = @document
        not_found unless @drilling_log_entry.document.company == current_user.company
        @drilling_log_entry.company = current_user.company
        @drilling_log_entry.job = @drilling_log.document.job
        @drilling_log_entry.user = current_user
        @drilling_log_entry.user_name = current_user.name
        @drilling_log_entry.bha = Bha.find(bha_id)

        if override_date.nil?
            @drilling_log_entry.entry_at = Time.now
        else
            @drilling_log_entry.entry_at = override_date
        end

        @last_entry = DrillingLogEntry.where(:company_id => current_user.company_id).where(:job_id => @document.job_id).last

        @drilling_log_entry.save

        if @last_entry.nil?
            @last_entry = @drilling_log_entry
        end
    end
end
