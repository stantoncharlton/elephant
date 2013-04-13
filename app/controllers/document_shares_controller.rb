class DocumentSharesController < ApplicationController
    before_filter :signed_in_user, only: [:index, :show, :new, :create, :destroy]

    def index
        @document = Document.find_by_id(params[:document])
        not_found unless @document.company == current_user.company
    end

    def new
        @document_share = DocumentShare.new
    end

    def create
        document_id = params[:document_share][:document]
        params[:document_share].delete(:document)

        @document = Document.find_by_id(document_id)
        not_found unless @document.company == current_user.company

        @document_share = DocumentShare.new(params[:document_share])
        @document_share.document = @document
        @document_share.shared_by = current_user
        @document_share.access_code = SecureRandom.urlsafe_base64[1..20]

        if @document_share.save
            @document_share.delay.send_share_email
        end
    end

    def show

    end

    def destroy
        @document_share = DocumentShare.find_by_id(params[:id])
        not_found unless @document_share.document.company == current_user.company

        @document_share.destroy
    end

end
