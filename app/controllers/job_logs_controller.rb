class JobLogsController < ApplicationController
    before_filter :signed_in_user, only: [:index, :create, :update]

    def index
        @document = Document.find(params[:document])
        not_found unless @document.company == current_user.company && @document.document_type == Document::JOB_LOG

        @job_logs = JobLog.where(:company_id => current_user.company_id).where(:document_id => @document.id).order("entry_at ASC")
    end

    def create
        document_id = params[:job_log][:document_id]
        params[:job_log].delete(:document_id)

        @job_log = JobLog.new(params[:job_log])
        @job_log.document = Document.find_by_id(document_id)
        not_found unless @job_log.document.company == current_user.company
        @job_log.company = current_user.company
        @job_log.job = @job_log.document.job
        @job_log.user = current_user

        if @job_log.entry_at.nil?
            @job_log.entry_at = Time.now
        end

        @job_log.save
    end

    def update

    end

end
