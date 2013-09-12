class DrillingLogsController < ApplicationController
    before_filter :signed_in_user, only: [:index, :create]

    def index
        @document = Document.find(params[:document])
        not_found unless !@document.nil?
        not_found unless @document.company == current_user.company && @document.document_type == Document::DRILLING_LOG

        @drilling_logs = DrillingLog.where(:company_id => current_user.company_id).where(:document_id => @document.id).order("entry_at ASC")
    end

    def create

    end
end
