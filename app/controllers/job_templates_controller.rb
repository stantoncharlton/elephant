class JobTemplatesController < ApplicationController
    before_filter :signed_in_admin, only: [:index, :show, :new, :create, :edit, :update, :destroy]


    def index
        @product_lines = ProductLine.from_company(current_user.company)

        @count = 0
        @product_lines.each do |product_line|
            @count += product_line.job_templates.count
        end
    end


    def show
        @job_template = JobTemplate.find(params[:id])
        not_found unless @job_template.company == current_user.company

        @new_document = Document.new
        @new_dynamic_field = DynamicField.new
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

        product_line_id = params[:job_template][:product_line_id]
        params[:job_template].delete(:product_line_id)

        @job_template = JobTemplate.new(params[:job_template])

        @fields = params[:job_template][:dynamic_fields]

        @job_template.company = current_user.company
        @job_template.product_line = ProductLine.find(product_line_id)

        if @job_template.save
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
        @job_template.product_line = ProductLine.find(product_line_id)

        if @job_template.update_attributes(params[:job_template])

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
        flash[:success] = "Job Template deleted."
        redirect_to job_templates_path
    end

end
