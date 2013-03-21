class JobTemplatesController < ApplicationController
    before_filter :signed_in_admin, only: [:index, :new, :create, :edit, :update, :destroy]
    before_filter :signed_in_user, only: [:show]
    set_tab :job_templates

    def index
        respond_to do |format|
            format.html {
                @product_lines = ProductLine.from_company(current_user.company).order("name ASC")

                @count = 0
                @product_lines.each do |product_line|
                    @count += product_line.job_templates.count
                end
            }
            format.json {
                @job_templates = JobTemplate.search(params, current_user.company).results
                render json: @job_templates.map { |job_template| {:label => job_template.name, :product_line => job_template.product_line.name, :segment => job_template.product_line.segment.name, :division => job_template.product_line.segment.division.name, :id => job_template.id} }
            }
        end
    end


    def show

        @job_template = JobTemplate.find(params[:id])
        not_found unless @job_template.company == current_user.company

        if signed_in_admin?
            @new_document = Document.new
            @new_dynamic_field = DynamicField.new
        else
            respond_to do |format|
                format.js {
                    render 'job_templates/show'
                }
                format.html {

                    @is_paged = params[:page].present?
                    if @is_paged
                        @jobs = @job_template.jobs.reorder('').order("jobs.created_at DESC").paginate(page: params[:page], limit: 20)
                    else
                        @jobs = @job_template.jobs.reorder('').where("jobs.status = :status_active OR (jobs.status = :status_closed AND jobs.close_date >= :close_date)", status_active: Job::ACTIVE, status_closed: Job::CLOSED, close_date: (Time.now - 5.days)).
                                order("jobs.created_at DESC")
                    end

                    render 'job_templates/show_jobs'
                }
            end
        end
    end

    def new
        @job_template = JobTemplate.new
        @job_template.product_line = ProductLine.find_by_id(params[:product_line])
        @product_lines = ProductLine.from_company(current_user.company)

        @documents = Array.new

        @value_types = Array.new
        @value_types << "String"
        @value_types << "Number"
        @value_types << "Boolean"
    end

    def create

        product_line = ProductLine.find_by_id(params[:job_template][:product_line_id])
        params[:job_template].delete(:product_line_id)
        not_found unless product_line.company == current_user.company

        @job_template = JobTemplate.new(params[:job_template])

        @fields = params[:job_template][:dynamic_fields]

        @job_template.company = current_user.company
        @job_template.product_line = product_line

        if @job_template.save

            Activity.add(self.current_user, Activity::JOB_TEMPLATE_CREATED, @job_template, @job_template.name)

            flash[:success] = "Job Template created - #{@job_template.name}"
            redirect_to @job_template
        else
            @product_lines = ProductLine.from_company(current_user.company)
            render 'new'
        end
    end

    def edit
        @job_template = JobTemplate.find(params[:id])
        not_found unless @job_template.company == current_user.company


        @product_lines = ProductLine.from_company(current_user.company)

        @value_types = Array.new
        @value_types << "String"
        @value_types << "Number"
        @value_types << "Boolean"
    end

    def update

        product_line_id = params[:job_template][:product_line_id]
        params[:job_template].delete(:product_line_id)

        @job_template = JobTemplate.find(params[:id])
        not_found unless @job_template.company == current_user.company

        @fields = params[:job_template][:dynamic_fields]
        @documents = params[:job_template][:document_fields]

        @job_template.company = current_user.company
        if product_line_id.present?
            @job_template.product_line = ProductLine.find(product_line_id)
        end

        if @job_template.update_attributes(params[:job_template])

            #Activity.add(self.current_user, Activity::JOB_TEMPLATE_UPDATED, @job_template, @job_template.name)

            flash[:success] = "Job Template updated"
            redirect_to job_templates_path
        else
            @product_lines = ProductLine.from_company(current_user.company)
            render 'edit'
        end
    end

    def destroy
        @job_template = JobTemplate.find(params[:id])
        not_found unless @job_template.company == current_user.company

        @job_template.destroy

        Activity.add(self.current_user, Activity::JOB_TEMPLATE_DESTROYED, @job_template, @job_template.name)

        flash[:success] = "Job Type deleted."
        redirect_to divisions_path
    end

end
