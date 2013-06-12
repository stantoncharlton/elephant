class FailuresController < ApplicationController
    before_filter :signed_in_user, only: [:index, :create, :show]
    before_filter :signed_in_admin, only: [:new, :update, :destroy]

    def index
        @job = Job.find_by_id(params[:job_id])
        not_found unless @job.company == current_user.company

        @rate = params[:rate] == "true"
    end

    def show
        @job = Job.find_by_id(params[:id])
        not_found unless @job.company == current_user.company

        jobs_query = Job.where("jobs.job_template_id = :job_template_id AND jobs.failures_count > 0", job_template_id: @job.job_template_id).select("jobs.id").to_sql
        failure_groups = Failure.includes(:failure_master_template).where("failures.job_id IN (#{jobs_query})").order("COUNT(failures.failure_master_template_id) DESC").select("failures.*, DISTINCT failures.failure_master_template_id").group("failures.failure_master_template_id").count()

        @failures = []

        failure_groups.each do |fg|
            master = Failure.find_by_id(fg[0])
            failure_list = Failure.where("failure_master_template_id = ?", master.id).limit(3)
            failure_list.select! { |f| f.job_id.present? && f.job_id != @job.id }
            if failure_list.any?
                @failures << [master, failure_list]
            end
        end

        respond_to do |format|
            format.js {
                render 'failures/show'
            }
            format.xml {
                render xml: @failures,
                       except: [:created_at, :updated_at, :company_id, :job_template_id, :product_line_id, :template]
            }
        end

    end

    def new
        @failure = Failure.new
        @failure.product_line = ProductLine.find_by_id(params[:product_line])
    end

    def create
        if signed_in_admin?
            failure_master_template_id = params[:failure][:failure_master_template_id]
            params[:failure].delete(:failure_master_template_id)

            product_line_id = params[:failure][:product_line_id]
            params[:failure].delete(:product_line_id)

            job_template_id = params[:failure][:job_template_id]
            params[:failure].delete(:job_template_id)

            @failure = Failure.new(params[:failure])
            @failure.company = current_user.company

            if !product_line_id.blank?
                @failure.product_line = ProductLine.find_by_id(product_line_id)
                not_found unless @failure.product_line.company == current_user.company
                @failure.template = true
            elsif !failure_master_template_id.blank?
                @failure.failure_master_template = Failure.find_by_id(failure_master_template_id)
                not_found unless @failure.failure_master_template.company == current_user.company

                @failure.job_template = JobTemplate.find_by_id(job_template_id)
                not_found unless @failure.job_template.company == current_user.company
            end

            @failure.save
        elsif params[:failures][:job_id]

            @rating = params[:performance_rating]

            @job = Job.find_by_id(params[:failures][:job_id])
            not_found unless @job.company == current_user.company

            Failure.transaction do
                @job.failures.each do |failure|
                    failure.destroy
                end
                @job.job_template.failures.each do |failure|
                    if params[:failures][failure.id.to_s] == "1"
                        job_failure = Failure.new
                        job_failure.company = current_user.company
                        job_failure.failure_master_template = failure.failure_master_template
                        job_failure.reference = params[failure.id.to_s + "_reference"]
                        job_failure.job = @job
                        job_failure.save

                        Activity.add(self.current_user, Activity::JOB_FAILURE, job_failure, nil, @job)
                    end
                end
            end

            if !@rating.blank?
                @job.update_attribute(:rating, @rating.to_i)
                Activity.add(self.current_user, Activity::JOB_RATING, @job, @rating.to_i, @job)
            end

            @job = Job.find_by_id(@job.id)

            render 'failures/update_list'
            return
        end
    end

    def update

    end

    def destroy
        @failure = Failure.find_by_id(params[:id])
        not_found unless  @failure.company == current_user.company
        @failure.destroy
    end
end
