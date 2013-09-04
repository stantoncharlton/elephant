class JobTimesController < ApplicationController
    before_filter :signed_in_user, only: [:update]

    def update
        @job = Job.find_by_id(params[:id])
        not_found unless @job.company == current_user.company
        @user = User.find_by_id(Integer(params[:user]))
        not_found unless @user.company == current_user.company

        if params[:schedule] == "true"
            JobTime.schedule(current_user.company, @job, @user, Time.strptime(params[:date], "%d-%m-%Y").in_time_zone(Time.zone), Integer(params[:hours]))
        elsif params[:worked] == "true"
            JobTime.worked(current_user.company, @job, @user, Time.strptime(params[:date], "%d-%m-%Y").in_time_zone(Time.zone), Integer(params[:hours]))
        elsif params[:none] == "true"
            JobTime.remove(current_user.company, @job, @user, Time.strptime(params[:date], "%d-%m-%Y").in_time_zone(Time.zone))
        end

        render :nothing => true, :status => 200
    end
end
