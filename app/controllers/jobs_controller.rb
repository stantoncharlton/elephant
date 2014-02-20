class JobsController < ApplicationController
    before_filter :signed_in_user, only: [:index, :show, :new, :create, :update, :destroy]
    set_tab :jobs

    def index

        @is_paged = params[:page].present?

        respond_to do |format|
            format.html {
                @jobs = current_user.jobs_list
                @jobs = Job.include_models(@jobs).includes(well: :drilling_log)

                #if !@is_paged
                #    if current_user.role.limit_to_assigned_jobs?
                #        @jobs = Job.include_models(@jobs).where("(jobs.status >= 1 AND jobs.status < 50) OR (jobs.status = :status_closed AND jobs.close_date >= :close_date)", status_closed: Job::COMPLETE, close_date: (Time.zone.now - 5.days))
                #    else
                #        @jobs = Job.include_models(@jobs).where("(jobs.status >= 1 AND jobs.status < 50)")
                #    end
                #else
                #    @jobs = Job.include_models(@jobs).order("jobs.created_at DESC").paginate(page: params[:page], limit: 20)
                #end

            }
            format.js {
                if !params[:search].blank?
                    @jobs = Job.search(current_user, params, current_user.company).results
                else
                    @jobs = current_user.jobs_list
                    @jobs = Job.include_models(@jobs).includes(well: :drilling_log)
                end
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
        if !params[:old_job].present?
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
        end

        Job.transaction do
            @job = Job.new(params[:job])
            @job.company = current_user.company
            @job.status = Job::PRE_JOB

            if params[:old_job].present?
                @old_job = Job.find_by_id(params[:old_job])
                @job.client = @old_job.client
                @job.job_template = @old_job.job_template

                if params[:job_type].present? && !params[:job_type].blank?
                    @job_template = JobTemplate.find_by_id(params[:job_type])
                    @job.job_template = @job_template
                end

                @job.district = @old_job.district
                @job.field = @old_job.field

                @new_well = Well.new
                @new_well.name = params[:well_name]
                @new_well.field = @old_job.field
                @new_well.location = @old_job.well.location
                @new_well.rig = @old_job.well.rig
                @new_well.save

                if @new_well.name.blank? || @new_well.new_record?
                    @job.errors.add(:well, "name must be present for rig skid")
                    flash[:error] = "Well name must be present to create new job."
                    redirect_to job_path(@old_job)
                    return
                end
                @job.well = @new_well
            else
                @job.client = Client.find_by_id(client_id)
                @job.job_template = JobTemplate.find_by_id(job_template_id)
                @job.district = District.find_by_id(district_id)
                @job.field = Field.find_by_id(field_id)
                @job.well = Well.find_by_id(well_id)
            end


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
                    job_dynamic_field.value = dynamic_field.value
                    job_dynamic_field.values = dynamic_field.values
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
                    job_document.access_level = document.access_level
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


                # Add to job as creator
                @job.add_user!(current_user, JobMembership::CREATOR)

                if params[:old_job].present? && @old_job.present?
                    @old_job.job_memberships.each do |jm|
                        if jm.job_role_id != JobMembership::CREATOR
                            job_membership = jm.duplicate
                            job_membership.job = @job
                            job_membership.save
                        end
                    end

                    @old_job.transfer_assets @job, current_user

                    @old_job.update_attribute(:status, Job::POST_JOB)
                    Activity.add(current_user, Activity::BEGIN_POST_JOB, @old_job, nil, @old_job)
                end

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
        end
    end

    def update
        @job = Job.find_by_id(params[:id])
        not_found unless !@job.nil?
        not_found unless @job.company == current_user.company

        if params[:update_field].present? && params[:update_field] == "true" &&
                params[:field].present? && params[:value].present?
            case params[:field]
                when "inventory_notes"
                    @job.update_attribute(:inventory_notes, params[:value])
                when "begin_pre_job"
                    @job.update_attribute(:status, Job::PRE_JOB)
                    if request.format == "html"
                        redirect_to @job
                    end
                when "begin_on_job"
                    @job.update_attribute(:status, Job::ON_JOB)
                    Activity.add(current_user, Activity::BEGIN_ON_JOB, @job, nil, @job)
                    @job.delay.begin_on_job
                    if request.format == "html"
                        redirect_to @job
                    end
                when "begin_post_job"
                    @job.update_attribute(:status, Job::POST_JOB)
                    Activity.add(current_user, Activity::BEGIN_POST_JOB, @job, nil, @job)
                    if request.format == "html"
                        redirect_to @job
                    end
                when "close_job"
                    @job.update_attribute(:status, Job::COMPLETE)
                    Activity.add(current_user, Activity::JOB_APPROVED_TO_CLOSE, @job, nil, @job)
                when "rating"
                    @job.update_attribute(:rating, params[:value])
                    Activity.add(self.current_user, Activity::JOB_RATING, @job, @job.rating.to_i, @job)
                    @rating_updated = true
                when "receive_shipment"
                    @shipment = Shipment.find_by_id(params[:value])
                    @shipment.receive_shipment current_user
                when "no_well_plan"
                    survey = @job.survey
                    if survey
                        @survey = Survey.find_by_id(survey.id)
                        @survey.update_attribute(:no_well_plan, true)
                        redirect_to drilling_log_path(@job.drilling_log, anchor: "survey")
                    end
            end
        else
            if params["start_date"].present?
                start = @job.start_date
                date = Date.today
                begin
                    date = Date.strptime(params["start_date"], '%m/%d/%Y')
                rescue
                    date = Date.strptime(params["start_date"], '%m-%d-%Y')
                end

                @job.update_attribute(:start_date, date.to_time_in_current_zone)
                Activity.add(self.current_user, Activity::START_DATE, @job, @job.start_date, @job)

                if start.present? && start != @job.start_date
                    change = @job.start_date - start
                    job_times = JobTime.where(:job_id => @job.id)
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
            end
        end
    end

    def destroy
        @job = Job.find_by_id(params[:id])
        not_found unless !@job.nil?
        not_found unless @job.company == current_user.company
        not_found unless @job.is_coordinator_or_creator?(current_user) || current_user.role.district_edit?

        if @job.part_memberships.any? && @job.part_memberships.where("part_memberships.shipping IS FALSE").any?
            flash[:error] = "All assets must be shipped to another job or back to warehouse in order to delete this job."
            redirect_to @job
        else

            @job.destroy
            flash[:success] = 'Job deleted.'
            redirect_to jobs_path
        end
    end
end
