class HistoryController < ApplicationController
    before_filter :signed_in_user, only: [:index]

    set_tab :history


    def index
        if params[:recap] && params[:recap] == "true"
            @jobs = current_user.role.no_assigned_jobs? ? current_user.company.jobs.reorder('') : current_user.jobs
            @jobs = @jobs.includes(dynamic_fields: :dynamic_field_template).includes(:job_memberships, :field, :well, :documents, :district, :client, :job_template => {:primary_tools => :tool}).includes(job_template: {product_line: {segment: :division}}).where("(jobs.status >= 1 AND jobs.status < 50) OR (jobs.status = :status_closed AND jobs.close_date >= :close_date)",  status_closed: Job::COMPLETE, close_date: (Time.now - 5.days)).
                    order("jobs.created_at DESC")

            render 'recap'
        else
            if current_user.role.no_assigned_jobs?
                @activities = Activity.activities_for_jobs(current_user.company.jobs).includes(:target, :user).includes(job: :well).includes(job: :field).includes(job: :district).includes(job: :client).includes(job: {job_template: {primary_tools: :tool}}).includes(job: {job_memberships: :user}).paginate(page: params[:page], limit: 50)
            else
                @activities = Activity.activities_for_jobs(current_user.jobs).includes(:target, :user).includes(job: :well).includes(job: :field).includes(job: :district).includes(job: :client).includes(job: {job_template: {primary_tools: :tool}}).includes(job: {job_memberships: :user}).paginate(page: params[:page], limit: 50)
            end

            render 'index'
        end
    end

end
