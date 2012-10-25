class JobsController < ApplicationController
    before_filter :signed_in_user, only: [:index, :show]
    before_filter :signed_in_user, only: [:new, :create]
    set_tab :jobs

    def index

        @jobs = Job.paginate(page: params[:page], limit: 10)

    end

    def show
        @job = Job.find_by_id(params[:id])
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

        Job.transaction do
            @job = Job.new(params[:job])
            @job.company = current_user.company
            @job.client = Client.find_by_id(client_id)
            @job.job_template = JobTemplate.find_by_id(job_template_id)
            @job.district = District.find_by_id(district_id)
            @job.field = Field.find_by_id(field_id)
            @job.well = Well.find_by_id(well_id)


            if @job.save
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
        end
    end
end
