class AlertsController < ApplicationController
    before_filter :signed_in_user, only: [:index]

    set_tab :alerts

    def index

        @alerts = current_user.alerts.includes(:company, :created_by, :user, :target).includes(job: {job_template: {primary_tools: :tool}}).where("alert_type != 3")

        @new_alerts = Array.new
        @old_alerts = Array.new

        @alerts.each do |alert|

            if alert.expiration.nil? or alert.expiration > 6.3.days.from_now or
                    alert.alert_type == Alert::PRE_JOB_DATA_READY or alert.alert_type == Alert::POST_JOB_DATA_READY
                @new_alerts << alert
            else
                @old_alerts << alert
            end

            alert.seen
        end

        @show_full_calendar = params[:calendar] == "true"
        @page = (params[:page] || "1").to_i
        @adjusted_today_date = Time.zone.now
        if @show_full_calendar
            @adjusted_today_date = @adjusted_today_date + (@page - 1).months
            @start_date = @adjusted_today_date.beginning_of_month.beginning_of_week - 1.days
        else
            @start_date = Time.zone.now.beginning_of_week - 1.days
        end

        @active_jobs = current_user.active_jobs

    end


end
