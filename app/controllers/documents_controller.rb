class DocumentsController < ApplicationController
    before_filter :signed_in_user, only: [:show, :new, :create, :update, :destroy]

    respond_to :js

    def show

        @document = Document.find(params[:id])
        not_found unless @document.company == current_user.company

        respond_to do |format|
            format.js {
                if params[:reorder].present?
                    if params[:reorder] == "-1"
                        if @document.ordering > 0
                            Document.transaction do
                                @document.ordering -= 1
                                @document.save

                                @document.document_collection.each do |document|
                                    if document != @document and (document.ordering || 0) == @document.ordering
                                        document.ordering = (document.ordering || 0) + 1
                                        document.save
                                    end
                                end
                            end

                            @move_up = true

                            render 'documents/reorder'
                        else
                            render :nothing => true, :status => :ok
                        end
                    end
                end
            }
            format.xml {
                render xml: @document,
                       :methods => [:full_url, :upload_info],
                       include: {
                               :document_template => {
                                       :methods => :full_url,
                               },
                               :user => {except: [:created_at, :updated_at, :password_digest, :remember_token, :elephant_admin, :create_password]}
                       }
            }
        end
    end

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
            @document.ordering = @document.document_collection.count

            if !@document.save
                render 'error'
            end

            Activity.add(self.current_user, Activity::DOCUMENT_CREATED, @document, @document.name)
        else

            @job = Job.find_by_id(job_id)
            not_found unless @job.company == current_user.company
            @document.job = @job
            @document.ordering = @document.document_collection.count

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
        @document.delete_document
        @document.url = params[:document][:url]


        @document.save

        if !@document.template?
            Activity.add(current_user, Activity::DOCUMENT_UPLOADED, @document, @document.file_name, @document.job)
        end

        respond_to do |format|
            format.js {
                render 'documents/update'
            }
            format.xml { render xml: @document,
                                :methods => :full_url,
                                include: {
                                        :document_template => {
                                                :methods => :full_url,
                                        },
                                        :user => {except: [:created_at, :updated_at, :password_digest, :remember_token, :elephant_admin, :create_password]}
                                }
            }
        end
    end


    def destroy
        @document = Document.find(params[:id])
        not_found unless @document.company == current_user.company
        @document.delete_document
        @document.destroy

        if !@document.destroy
            render 'error'
        end

        Activity.add(self.current_user, Activity::DOCUMENT_DESTROYED, @document, @document.name)

    end

end
