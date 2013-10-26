class DrillingLogEntriesController < ApplicationController
    before_filter :signed_in_user, only: [:new, :create, :destroy]

    def new

    end

    def create
        drilling_log_id = params[:drilling_log_entry][:drilling_log_id]
        params[:drilling_log_entry].delete(:drilling_log_id)

        bha_id = params[:drilling_log_entry][:bha_id]
        params[:drilling_log_entry].delete(:bha_id)
        if !bha_id.blank?
            @bha = Bha.find_by_id(bha_id)
        end

        @drilling_log = DrillingLog.find_by_id(drilling_log_id)

        override_date = nil
        if params[:drilling_log_entry][:override_date] == "1"
            override_date = Time.strptime("#{params[:date]} #{params[:hour]}:#{params[:minute]}:00 #{params[:meridian]}", '%m/%d/%Y %I:%M:%S %p').in_time_zone(Time.zone)
        end

        params[:drilling_log_entry].delete(:override_date)

        @drilling_log_entry = DrillingLogEntry.new(params[:drilling_log_entry])
        @drilling_log_entry.drilling_log = @drilling_log
        @drilling_log_entry.company = current_user.company
        @drilling_log_entry.job = @drilling_log.document.job
        @drilling_log_entry.user = current_user
        @drilling_log_entry.user_name = current_user.name
        @drilling_log_entry.bha = @bha

        if override_date.nil?
            @drilling_log_entry.entry_at = Time.now
        else
            @drilling_log_entry.entry_at = override_date
        end

        @last_entry = DrillingLogEntry.where(:company_id => current_user.company_id).where(:job_id => @drilling_log.job_id).last

        @drilling_log_entry.save

        @drilling_log.recalculate

        if @last_entry.nil?
            @last_entry = @drilling_log_entry
        end
    end

    def destroy

    end

end
