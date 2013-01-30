class JobsController < ApplicationController
    before_filter :signed_in_user, only: [:index, :show, :new, :create, :update]
    set_tab :jobs

    def index

        respond_to do |format|
            format.html {
                @jobs = current_user.active_jobs
                @jobs_inactive = current_user.inactive_jobs.paginate(page: params[:page], limit: 5)
            }
            format.xml {
                render xml: current_user.active_jobs,
                       include: {
                               #:status => {},
                               :field => {except: [:created_at, :updated_at, :company_id]},
                               :well => {except: [:created_at, :updated_at, :company_id]},
                               :district => {except: [:created_at, :updated_at, :company_id]},
                               :company => {except: [:created_at, :updated_at, :company_id]},
                               :client => {except: [:created_at, :updated_at, :company_id]},
                               :dynamic_fields => {except: [:created_at, :updated_at, :company_id]},
                               :job_template => {
                                       include: {
                                               :product_line => {
                                                       include: {
                                                               :segment => {
                                                                       include: {:division => {except: [:created_at, :updated_at, :company_id]}},
                                                                       except: [:created_at, :updated_at, :company_id]
                                                               }
                                                       },
                                                       except: [:created_at, :updated_at, :segment_id, :company_id]
                                               }
                                       },
                                       except: [:created_at, :updated_at, :product_line_id, :company_id]
                               },
                               :documents => {
                                       :methods => :full_url,
                                       include: {
                                               :document_template => {
                                                       :methods => :full_url,
                                               },
                                               :user => {except: [:created_at, :updated_at, :password_digest, :remember_token, :elephant_admin, :create_password]}
                                       }
                               },
                               :job_notes => {}

                       }
            }
        end
    end

    def show
        @job = Job.find_by_id(params[:id])
        not_found unless @job.company == current_user.company
        not_found unless @job.can_user_view?(current_user)

        #@activities = Activity.activities_for_job(@job)

        @job_note = JobNote.new
        @job_member = JobMembership.new

        @pre_job_documents = @job.pre_job_documents
        @post_job_documents = @job.post_job_documents
        @field_bulletin_documents = @job.notices_documents

        @activities = Activity.activities_for_job(@job).paginate(page: params[:page], limit: 10)

        @job_editable = @job.is_job_editable?(current_user)
    end

    def new
        @job = Job.new
        @job.district = current_user.district

        if !@job.district.nil?
            @fields = @job.district.fields
        else
            @fields = Array.new
        end

        @divisions = current_user.company.divisions
        @segments = Array.new
        @product_lines = Array.new
        @job_templates = Array.new
        @clients = current_user.company.clients
        @districts = current_user.company.districts

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

        if @job.well.field != @job.field
            @job.errors.add(:well, "Well does not belong to field")
        end

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

            # Add to job as creator
            @job.add_user!(current_user, 6)

            Activity.add(self.current_user, Activity::JOB_CREATED, @job, nil, @job)

            flash[:success] = "Job created"
            redirect_to @job
        else
            @divisions = current_user.company.divisions
            @segments = !@job.job_template.nil? ? @job.job_template.product_line.segment.division.segments : Array.new
            @product_lines = !@job.job_template.nil? ? @job.job_template.product_line.segment.product_lines : Array.new
            @job_templates = !@job.job_template.nil? ? @job.job_template.product_line.job_templates : Array.new
            @clients = current_user.company.clients
            @districts = current_user.company.districts

            if !@job.district.nil?
                @fields = @job.district.fields
            else
                @fields = Array.new
            end

            if !@job.field.nil?
                @wells = @job.field.wells
            else
                @wells = Array.new
            end

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
            @job.sales_engineer = @user
        end

        @job.save

        if @user.present?
            @job.add_user!(@user)
        end

    end
end
