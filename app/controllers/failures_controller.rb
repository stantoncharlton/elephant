class FailuresController < ApplicationController
    before_filter :signed_in_user, only: [:index, :create]
    before_filter :signed_in_admin, only: [:new, :update, :destroy]

    def index
        @job = Job.find_by_id(params[:job_id])
        not_found unless @job.company == current_user.company

        @rate = params[:rate]
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
                        job_failure.job = @job
                        job_failure.save
                    end
                end
            end

            if !@rating.nil?
                @job.update_attribute(:performance_rating, @rating.to_i)
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
