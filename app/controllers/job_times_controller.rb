class JobTimesController < ApplicationController
    before_filter :signed_in_user, only: [:index, :update]


    def index

        @page = (params[:page] || "1").to_i
        @adjusted_today_date = Time.now
        puts @page.to_s + "...................[age"
        @adjusted_today_date = @adjusted_today_date + (@page - 1).months
        @start_date = @adjusted_today_date.beginning_of_month.beginning_of_week - 1.days
        puts @adjusted_today_date.to_s + "..................."
        puts @start_date.to_s + "..................."

        @user = User.find_by_id(params[:user])
        not_found unless @user.company == current_user.company

        @job_times = JobTime.where(:company_id => current_user.company_id).where(:user_id => @user.id).where("job_times.time_for > :start_date AND job_times.time_for < :end_date", start_date: @adjusted_today_date - 1.month, end_date: @adjusted_today_date + 1.month)

    end

    def update
        @job = Job.find_by_id(params[:id])
        not_found unless @job.company == current_user.company
        @user = User.find_by_id(Integer(params[:user]))
        not_found unless @user.company == current_user.company

        if params[:schedule] == "true"
            JobTime.schedule(current_user.company, @job, @user, Date.strptime(params[:date], "%d-%m-%Y").to_time_in_current_zone, Integer(params[:hours]))
        elsif params[:worked] == "true"
            JobTime.worked(current_user.company, @job, @user, Date.strptime(params[:date], "%d-%m-%Y").to_time_in_current_zone, Integer(params[:hours]))
        elsif params[:none] == "true"
            JobTime.remove(current_user.company, @job, @user, Date.strptime(params[:date], "%d-%m-%Y").to_time_in_current_zone)
        end

        render :nothing => true, :status => 200
    end
end