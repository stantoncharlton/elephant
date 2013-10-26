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
        @bhas = Bha.where(:company_id => current_user.company_id).where(:job_id => @drilling_log.job_id)
    end


end
