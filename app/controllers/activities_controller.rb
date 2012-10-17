class ActivitiesController < ApplicationController

    def index
        @activities = Activity.admin_activities_for_company(current_user.company).paginate(page: params[:page], limit: 10)
    end
end
