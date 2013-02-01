class HistoryController < ApplicationController
    before_filter :signed_in_user, only: [:index]

    set_tab :history


    def index
        @activities = Activity.activities_for_jobs(current_user.jobs).group('activities.job_id, activities.id').paginate(page: params[:page], limit: 10)
    end

end
