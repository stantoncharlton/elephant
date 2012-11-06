class JobsController < ApplicationController
    before_filter :signed_in_user, only: [:index, :show]
    before_filter :signed_in_user, only: [:new, :create, :update]
    set_tab :jobs

    def index

        @jobs = Job.from_user(current_user).paginate(page: params[:page], limit: 10)

    end

    def show
        @job = Job.find_by_id(params[:id])
        not_found unless @job.company == current_user.company

        @activities = Activity.activities_for_job(@job)

        @job_note = JobNote.new
    end

    def new
        @job = Job.new

        @product_lines = current_user.company.product_lines
        @job_templates = Array.new
        @clients = current_user.company.clients
        @districts = current_user.company.districts
        @fields = current_user.company.fields
        @wells = Array.new
    end

    def create
        job_template_id = params[:job][:job_template_id]
        params[:job].delete(:job_template_id)

        client_id = params[:job][:client_id]
        params[:job].delete(:client_id)

        district_id = params[:job][:district_id]
        params[:job].delete(:district_id)

        field_id = params[:job][:field_id]
        params[:job].delete(:field_id)

        well_id = params[:job][:well_id]
        params[:job].delete(:well_id)

        #Job.transaction do
        @job = Job.new(params[:job])
        @job.company = current_user.company
        @job.client = Client.find_by_id(client_id)
        @job.job_template = JobTemplate.find_by_id(job_template_id)
        @job.district = District.find_by_id(district_id)
        @job.field = Field.find_by_id(field_id)
        @job.well = Well.find_by_id(well_id)


        if @job.save

            @job.job_template.dynamic_fields.each do |dynamic_field|
                job_dynamic_field = dynamic_field.dup
                job_dynamic_field.template = false
                job_dynamic_field.dynamic_field_template = dynamic_field
                job_dynamic_field.job_template = @job.job_template
                job_dynamic_field.job = @job
                job_dynamic_field.company = current_user.company
                job_dynamic_field.save
            end

            @job.job_template.documents.each do |document|
                job_document = document.dup
                job_document.template = false
                job_document.url = nil
                job_document.document_template = document
                job_document.job_template = @job.job_template
                job_document.job = @job
                job_document.company = current_user.company
                job_document.save
            end

            @job.add_user!(current_user)

            Activity.add(self.current_user, Activity::JOB_CREATED, @job, nil, @job)

            flash[:success] = "Job created"
            redirect_to @job
        else
            @product_lines = current_user.company.product_lines
            @job_templates = Array.new
            @clients = current_user.company.clients
            @districts = current_user.company.districts
            @fields = current_user.company.fields
            @wells = Array.new

            render 'new'
        end
        #end
    end

    def update
        @job = Job.find_by_id(params[:id])
        not_found unless @job.company == current_user.company

        district_manager_id = params[:job][:district_manager_id]
        params[:job].delete(:district_manager_id)

        sales_engineer_id = params[:job][:sales_engineer_id]
        params[:job].delete(:sales_engineer_id)

        if district_manager_id.present?
            @user = User.find_by_id(district_manager_id)
            if @job.district_manager.present?
                @job.remove_user!(@user)
            end
            @tag_name = 'district_manager'
            @job.district_manager = @user
        elsif sales_engineer_id.present?
            @user = User.find_by_id(sales_engineer_id)
            if @job.sales_engineer.present?
                @job.remove_user!(@user)
            end
            @tag_name = 'sales_engineer'
            @job.sales_engineer =  @user
        end

        @job.save

        if @user.present?
            @job.add_user!(@user)
        end

    end
end
