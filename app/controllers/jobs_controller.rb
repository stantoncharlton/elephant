class JobsController < ApplicationController
    before_filter :signed_in_user, only: [:index, :show, :new, :create, :update, :destroy]
    set_tab :jobs

    def index

        @is_paged = params[:page].present?

        respond_to do |format|
            format.html {
                @all_jobs = current_user.role.no_assigned_jobs? ? current_user.company.jobs.reorder('') : current_user.jobs
                @jobs = @all_jobs

                if !@is_paged
                    @jobs = @all_jobs.where("(jobs.status >= 1 AND jobs.status < 50) OR (jobs.status = :status_closed AND jobs.close_date >= :close_date)", status_closed: Job::COMPLETE, close_date: (Time.now - 5.days))
                end

                @jobs = @jobs.includes(dynamic_fields: :dynamic_field_template).includes(:job_memberships, :field, :well, :job_processes, :documents, :district, :client, :job_template => {:primary_tools => :tool}).includes(job_template: {product_line: {segment: :division}}).
                        order("jobs.created_at DESC").paginate(page: params[:page], limit: 20)
            }
            format.xml {
                render xml: current_user.active_or_recently_closed_jobs,
                       :methods => [:status_string, :status_percentage],
                       include: {
                               :field => {except: [:created_at, :updated_at, :company_id]},
                               :well => {except: [:created_at, :updated_at, :company_id]},
                               :district => {except: [:created_at, :updated_at, :company_id]},
                               :company => {except: [:created_at, :updated_at, :company_id]},
                               :client => {except: [:created_at, :updated_at, :company_id]},
                               :dynamic_fields => {except: [:created_at, :updated_at, :company_id]},
                               :job_template => {
                                       include: {
                                               :post_job_report_documents => {except: [:created_at, :updated_at]},
                                               :product_line => {
                                                       include: {
                                                               :segment => {
                                                                       include: {:division => {except: [:created_at, :updated_at, :company_id]}},
                                                                       except: [:created_at, :updated_at, :company_id]
                                                               }
                                                       },
                                                       except: [:created_at, :updated_at, :segment_id, :company_id]
                                               },
                                               :primary_tools => {
                                                       include: {:tool => {}}
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
        not_found unless !@job.nil?
        not_found unless @job.company == current_user.company
        not_found unless @job.can_user_view?(current_user)

        @job_editable = @job.is_job_editable?(current_user)

        if params[:section].blank?
            #@activities = Activity.activities_for_job(@job)

            @job_note = JobNote.new
            @job_member = JobMembership.new

            @activities = [] #.paginate(page: params[:page], limit: 10)

        end
    end

    def new
        @job = Job.new
        @job.district = current_user.district

        if !@job.district.nil? && !@job.district.master_district.nil?
            @fields = []
            @job.district.master_district.districts.includes(:fields).each do |d|
                d.fields.each do |field|
                    @fields << field
                end
            end
        else
            @fields = Array.new
        end

        @divisions = current_user.company.divisions
        if current_user.product_line.present?
            @segments = current_user.product_line.segment.division.segments
            @product_lines = current_user.product_line.segment.product_lines
            @job_templates = current_user.product_line.job_templates.includes(primary_tools: :tool)

            @division = current_user.product_line.segment.division
            @segment = current_user.product_line.segment
            @product_line = current_user.product_line
        else
            @segments = Array.new
            @product_lines = Array.new
            @job_templates = Array.new
        end

        @clients = current_user.company.clients
        @districts = current_user.company.districts

        @wells = Array.new

        if params[:well]
            @job.well = Well.find_by_id(params[:well])
            @job.district = @job.well.field.district
            @fields = @job.district.fields
            @job.field = @job.well.field
            @wells = @job.field.wells
            @job.client = @job.well.jobs.any? ? @job.well.jobs.first.client : nil
        end
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
        @job.status = Job::PRE_JOB

        if @job.well.present? && (@job.well.field != @job.field)
            @job.errors.add(:well, "Well does not belong to field")
        end

        if @job.save

            @job.job_template.dynamic_fields.each do |dynamic_field|
                job_dynamic_field = DynamicField.new
                job_dynamic_field.name = dynamic_field.name
                job_dynamic_field.value_type = dynamic_field.value_type
                job_dynamic_field.optional = dynamic_field.optional
                job_dynamic_field.priority = dynamic_field.priority
                job_dynamic_field.predefined = dynamic_field.predefined
                job_dynamic_field.ordering = dynamic_field.ordering
                job_dynamic_field.template = false
                job_dynamic_field.dynamic_field_template = dynamic_field
                job_dynamic_field.job_template = @job.job_template
                job_dynamic_field.job = @job
                job_dynamic_field.company = current_user.company
                job_dynamic_field.save
            end

            @job.job_template.documents.each do |document|
                job_document = Document.new
                job_document.category = document.category
                job_document.name = document.name
                job_document.status = document.status
                job_document.document_type = document.document_type
                job_document.read_only = document.read_only
                job_document.ordering = document.ordering
                job_document.template = false
                job_document.url = nil
                job_document.document_template = document
                job_document.job_template = @job.job_template
                job_document.job = @job

                if !document.primary_tool_id.blank?
                    job_document.primary_tool_id = document.primary_tool_id
                end

                job_document.company = current_user.company
                job_document.save
            end

            @job.job_template.primary_tools.where(:template => true).each do |primary_tool|
                tool = PrimaryTool.new
                tool.template = false
                tool.tool = primary_tool.tool
                tool.job = @job
                tool.job_template = primary_tool.job_template
                tool.company = current_user.company

                if tool.save
                    primary_tool.documents.order("created_at ASC").each do |document|
                        new_document = document.duplicate
                        new_document.url = nil
                        new_document.primary_tool_id = tool.id
                        new_document.save
                    end
                    primary_tool.part_memberships.where(:template => true).order("created_at ASC").each do |part_membership|
                        new_part_membership = part_membership.duplicate
                        new_part_membership.part = nil
                        new_part_membership.template = true
                        new_part_membership.primary_tool = tool
                        new_part_membership.save
                    end
                end
            end

            # Add to job as creator
            @job.add_user!(current_user, JobMembership::CREATOR)

            Activity.add(self.current_user, Activity::JOB_CREATED, @job, nil, @job)

            flash[:success] = "Job created, add extra job data below."
            redirect_to job_path(@job, new: "true")
        else

            @clients = current_user.company.clients
            @districts = current_user.company.districts

            @divisions = current_user.company.divisions
            if @job.job_template.present?
                @segments = @job.job_template.product_line.segment.division.segments
                @product_lines = @job.job_template.product_line.segment.product_lines
                @job_templates = @job.job_template.product_line.job_templates

                @division = @job.job_template.product_line.segment.division
                @segment = @job.job_template.product_line.segment
                @product_line = @job.job_template.product_line
            else
                if current_user.product_line.present?
                    @segments = current_user.product_line.segment.division.segments
                    @product_lines = current_user.product_line.segment.product_lines
                    @job_templates = current_user.product_line.job_templates

                    @division = current_user.product_line.segment.division
                    @segment = current_user.product_line.segment
                    @product_line = current_user.product_line
                else
                    @segments = Array.new
                    @product_lines = Array.new
                    @job_templates = Array.new
                end
            end

            if !@job.district.nil? && !@job.district.master_district.nil?
                @fields = []
                @job.district.master_district.districts.each do |d|
                    d.fields.each do |field|
                        @fields << field
                    end
                end
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
        not_found unless !@job.nil?
        not_found unless @job.company == current_user.company

        if params["start_date"].present?
            start = @job.start_date
            @job.update_attribute(:start_date, Date.strptime(params["start_date"], '%m/%d/%Y').to_time_in_current_zone)
            Activity.add(self.current_user, Activity::START_DATE, @job, @job.start_date, @job)

            if start.present? && start != @job.start_date
                change = @job.start_date - start
                job_times = JobTime.where(:company_id => @job.company_id).where(:job_id => @job.id)
                if job_times.any?
                    @job_times_changed = true
                    @update_calendar = true
                end
                job_times.each do |jt|
                    jt.time_for = jt.time_for + change
                    jt.save
                end
            else
                @update_calendar = true
            end

        elsif params["begin_post_job"] == "true"
            @job.update_attribute(:status, Job::POST_JOB)
            JobProcess.record(current_user, @job, current_user.company, JobProcess::BEGIN_POST_JOB)
            Activity.add(current_user, Activity::ON_JOB_COMPLETE, @job, nil, @job)
        end

    end

    def destroy
        @job = Job.find_by_id(params[:id])
        not_found unless !@job.nil?
        not_found unless @job.company == current_user.company
        not_found unless @job.is_coordinator_or_creator?(current_user) || current_user.role.district_edit?
        @job.destroy

        #Activity.add(self.current_user, Activity::PRODUCT_LINE_DESTROYED, @product_line, @product_line.name)

        flash[:success] = 'Job deleted.'

        redirect_to jobs_path
    end
end
