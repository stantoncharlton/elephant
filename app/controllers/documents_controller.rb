class DocumentsController < ApplicationController
    before_filter :signed_in_user, only: [:new, :create, :update, :destroy]

    respond_to :js

    def new

        if params["modal"].present? && params["modal"] == "true"
            @job_id = params[:job_id]
            @document = Document.new
           render 'documents/new_modal'
        else

            @document = Document.new(params[:document])
            @filename ||= File.basename(@document.url)

            render 'documents/new'
        end

    end

    def create

        job_id = params[:document][:job_id]
        params[:document].delete(:job_id)

        job_template_id = params[:document][:job_template_id]
        params[:document].delete(:job_template_id)

        @document = Document.new(params[:document])
        @document.company = current_user.company

        if @document.template?

            @document.job_template = JobTemplate.find_by_id(job_template_id)

            if !@document.save
                render 'error'
            end

            Activity.add(self.current_user, Activity::DOCUMENT_CREATED, @document, @document.name)
        else

            @job = Job.find_by_id(job_id)
            not_found unless @job.company == current_user.company
            @document.job = @job

            if @document.save
                render 'documents/create_modal'
            else
                render 'error'
            end

        end

    end

    def update
        @document = Document.find(params[:id])
        not_found unless @document.company == current_user.company

        if @document.template?
            not_found unless signed_in_admin?
        end

        @document.user = current_user
        @document.url = params[:document][:url]


        @document.save

        if !@document.template?
            Activity.add(current_user, Activity::DOCUMENT_UPLOADED, @document, @document.file_name, @document.job)
        end

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
