class JobTemplatesController < ApplicationController
    before_filter :signed_in_admin, only: [:index, :new, :create, :edit, :update, :destroy]
    before_filter :signed_in_user, only: [:show]
    set_tab :job_templates

    def index
        @product_lines = ProductLine.from_company(current_user.company).order("name ASC")

        @count = 0
        @product_lines.each do |product_line|
            @count += product_line.job_templates.count
        end
    end


    def show

        @job_template = JobTemplate.find(params[:id])
        not_found unless @job_template.company == current_user.company

        if signed_in_admin?
            @new_document = Document.new
            @new_dynamic_field = DynamicField.new
        else
            @jobs = JobTemplate.from_company_for_user(@job_template, params, current_user, current_user.company).results
            render 'job_templates/show_jobs'
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

        flash[:success] = "Job Template deleted."
        redirect_to job_templates_path
    end

end
