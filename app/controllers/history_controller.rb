class HistoryController < ApplicationController
    before_filter :signed_in_user, only: [:index]

    set_tab :history


    def index
        @activities = Activity.activities_for_jobs(current_user.jobs).paginate(page: params[:page], limit: 5)
    end

end
