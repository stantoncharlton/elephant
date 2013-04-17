class DocumentSharesController < ApplicationController
    before_filter :signed_in_user, only: [:index, :new, :create, :update, :destroy]

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
        @document_share = DocumentShare.find_by_id(params[:id])
        @access_code = params[:access_code]
        not_found unless @document_share.access_code == @access_code

        if params[:download].present? && params[:download] == "true"
            redirect_to @document_share.document.full_url
        elsif params[:add_to_job].present? && params[:add_to_job] == "true"
            return signed_in_user unless signed_in?
            #not_found unless @document_share.email.downcase == current_user.email.downcase
            render 'show'
        else
            not_found
        end
    end

    def update
        @document_share = DocumentShare.find_by_id(params[:id])
        @access_code = params[:document_share][:access_code]
        not_found unless @document_share.access_code == @access_code

        @job = Job.find_by_id(params[:document_share][:job])
        not_found unless @job.company == current_user.company

        if params[:document_share][:add_to_job].present? && params[:document_share][:add_to_job] == "true"
            #not_found unless @document_share.email.downcase == current_user.email.downcase

            @document_share.job = @job
            if @document_share.save
                flash[:success] = "Shared document '" + @document_share.document.name + "' added to job."
                redirect_to @job
                return
            end

            puts @document_share.errors.full_messages
        end
    end

    def destroy
        @document_share = DocumentShare.find_by_id(params[:id])
        not_found unless @document_share.document.company == current_user.company

        @document_share.destroy
    end

end
