class HistoryController < ApplicationController
    before_filter :signed_in_user, only: [:index]

    set_tab :history


    def index
        @activities = Activity.activities_for_jobs(current_user.jobs).includes(:target, :user).includes(job: :well).includes(job: :field).includes(job: :district).includes(job: :client).includes(job: :job_processes).includes(job: { job_template: { primary_tools: :tool } }).includes(job: { job_memberships: :user }).paginate(page: params[:page], limit: 5)
    end

end
