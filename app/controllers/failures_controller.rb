class FailuresController < ApplicationController
    before_filter :signed_in_admin, only: [:new, :create, :update, :destroy]

    def new
        @failure = Failure.new
        @failure.product_line = ProductLine.find_by_id(params[:product_line])
    end

    def create
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
    end

    def update

    end

    def destroy
        @failure = Failure.find_by_id(params[:id])
        not_found unless  @failure.company == current_user.company
        @failure.destroy
    end
end
