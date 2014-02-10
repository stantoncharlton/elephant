class JobTimesController < ApplicationController
    before_filter :signed_in_user, only: [:index, :update]

    include JobTimesHelper

    def index

        if params[:user].present?
            @page = (params[:page] || "1").to_i
            @adjusted_today_date = Time.zone.now
            @adjusted_today_date = @adjusted_today_date + (@page - 1).months
            @start_date = @adjusted_today_date.beginning_of_month.beginning_of_week - 1.days

            @user = User.find_by_id(params[:user])
            not_found unless @user.company == current_user.company

            @job_times = JobTime.where(:company_id => current_user.company_id).where(:user_id => @user.id).where("job_times.time_for > :start_date AND job_times.time_for < :end_date", start_date: @adjusted_today_date - 1.month, end_date: @adjusted_today_date + 1.month)
        elsif params[:job].present?
            @page = (params[:page] || "0").to_i
            @job = Job.find_by_id(params[:job])
            not_found unless @job.company == current_user.company

            @start_date = Time.zone.now
            if @page != 0
                @start_date = @start_date + (@page * 10.days)
            end
        else
            if params[:district].present?
                @district = District.find_by_id(params[:district])
            elsif current_user.district.present?
                @district = current_user.district
            elsif current_user.company.districts.where(:master => true).count == 1
                @district = current_user.company.districts.where(:master => true).first.districts.first
            else
                @district = nil
            end

            not_found unless @district.present?

            @page = (params[:page] || "0").to_i
            @adjusted_today_date = Time.zone.now

            @start_date = Time.zone.now.beginning_of_week
            if @start_date.strftime("%U").to_i % 2 != 0
                @start_date = @start_date - 1.week
            else
                @start_date = @start_date - 2.weeks
            end

            if @page != 0
                @start_date = @start_date + (@page * 14.days)
            end

            respond_to do |format|
                format.xlsx {
                    excel = job_times_to_excel @start_date
                    send_data excel.to_stream.read, :filename => "Timesheet (#{@start_date.strftime("%m-%d")} #{(@start_date + 14.days).strftime("%m-%d")}).xlsx", :type => "application/vnd.openxmlformates-officedocument.spreadsheetml.sheet"
                }
                format.all {
                }
            end
        end
    end

    def update
        @job = Job.find_by_id(params[:id])
        not_found unless @job.company == current_user.company
        @user = User.find_by_id(Integer(params[:user]))
        not_found unless @user.company == current_user.company

        if params[:schedule] == "true"
            JobTime.schedule(current_user.company, @job, @user, Date.strptime(params[:date], "%d-%m-%Y").to_time_in_current_zone, Float(params[:hours]))
        elsif params[:worked] == "true"
            JobTime.worked(current_user.company, @job, @user, Date.strptime(params[:date], "%d-%m-%Y").to_time_in_current_zone, Float(params[:hours]))
        elsif params[:none] == "true"
            JobTime.remove(current_user.company, @job, @user, Date.strptime(params[:date], "%d-%m-%Y").to_time_in_current_zone)
        end

        render :nothing => true, :status => 200
    end
end
