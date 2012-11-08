class ActivitiesController < ApplicationController
    before_filter :signed_in_user, only: [:index]

    def index

        respond_to do |format|
            format.js {
                @job = Job.find_by_id(params[:job_id])
                not_found unless @job.company == current_user.company

                @activities = Activity.activities_for_job(@job)
            }
            format.html {
                @activities = Activity.admin_activities_for_company(current_user.company).paginate(page: params[:page], limit: 10)
            }
        end
    end
end
