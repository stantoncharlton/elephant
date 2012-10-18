class DocumentsController < ApplicationController
    before_filter :signed_in_admin, only: [:new, :create, :update, :destroy]

    respond_to :js

    def new
        @document = Document.new(params[:document])

        @filename ||= File.basename(@document.url)
    end

    def create

        job_template_id = params[:document][:job_template_id]
        params[:document].delete(:job_template_id)

        @document = Document.new(params[:document])
        @document.company = current_user.company
        @document.job_template = JobTemplate.find_by_id(job_template_id)

        if !@document.save
            render 'error'
        end

        Activity.add(self.current_user, Activity::DOCUMENT_CREATED, @document, @document.name)

    end

    def update
        @document = Document.find(params[:id])
        not_found unless @document.company == current_user.company
        @document.update_attribute(:url, params[:document][:url])
    end


    def destroy
        @document = Document.find(params[:id])
        not_found unless @document.company == current_user.company
        @document.destroy

        if !@document.destroy
            render 'error'
        end

        Activity.add(self.current_user, Activity::DOCUMENT_DESTROYED, @document, @document.name)

    end

end