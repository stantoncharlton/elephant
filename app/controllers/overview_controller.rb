class OverviewController < ApplicationController
    include JobAnalysisHelper
    before_filter :signed_in_user, only: [:overview]

    set_tab :overview

    def overview

        if params[:section] == "company"
            @jobs = Job.from_company(current_user.company).includes(:district, :client, :dynamic_fields, :field, :well).includes(job_template: {product_line: {segment: :division}})
            filter

            @personnel_utilization = personnel_utilization(@jobs)
            @total_personnel = total_personnel(@jobs)
            @total_districts = total_districts(@jobs)
            @total_job_types = total_job_types(@jobs)
            @average_job_time = average_job_duration(@jobs)
            @average_job_performance = average_job_performance(@jobs)
            @jobs = @jobs.reorder('').order("jobs.created_at DESC").paginate(page: params[:page], limit: 10)
        elsif  params[:section] == "company_failures"
            @jobs = Job.from_company(current_user.company).includes(:district, :client, :dynamic_fields, :field, :well).includes(job_template: {product_line: {segment: :division}})
            filter
            @job_success_rate = job_success_rate(@jobs)
            @failures = failures(@jobs)
            @failures_list = @failures.take(4).to_a
            @failures_count = @failures.count()
        end

        render 'overview'
    end

    def filter

        @jobs = UserRole.limit_jobs_scope current_user, @jobs

        @district_id = params[:district_id]
        @division_id = params[:division_id]
        @user_id = params[:user_id]
        @time = params[:time].blank? ? "all" : params[:time]
        @rating = params[:rating].blank? ? "all" : params[:rating]
        @failure_level = params[:failure_level].blank? ? "all" : params[:failure_level]
        @filters_open = params[:filters_open].blank? ? "" : params[:filters_open]

        if !@district_id.blank?
            @jobs = @jobs.where("jobs.district_id = ?", @district_id)
            @district_name = District.find_by_id(@district_id).name
        end

        if !@division_id.blank?
            parts = @division_id.split("/////")
            case parts.first.downcase
                when "division"
                    @division_name = Division.find_by_id(parts.last).name
                    @jobs = @jobs.joins(job_template: {product_line: {segment: :division}}).where("divisions.id = ?", parts.last)
                when "segment"
                    @division_name = Segment.find_by_id(parts.last).name
                    @jobs = @jobs.joins(job_template: {product_line: :segment}).where("segments.id = ?", parts.last)
                when "product line"
                    @division_name = ProductLine.find_by_id(parts.last).name
                    @jobs = @jobs.joins(job_template: :product_line).where("product_lines.id = ?", parts.last)
                when "job template"
                    @division_name = JobTemplate.find_by_id(parts.last).name
                    @jobs = @jobs.joins(:job_template).where("job_templates.id = ?", parts.last)
            end
        end

        if !@user_id.blank?
            @user = User.find_by_id(@user_id)
            not_found unless @user.company == current_user.company
            user_jobs_query = @user.jobs.reorder('').select("jobs.id").to_sql
            @jobs = @jobs.where("jobs.id IN (#{user_jobs_query})")
            @user_name = @user.name
        end

        @start_date = 50.years.ago
        @end_date = 1.year.from_now
        case @time
            when "30"
                @start_date = 30.days.ago
            when "previous 30"
                @start_date = 60.days.ago
                @end_date = 30.days.ago
            when "60"
                @start_date = 60.days.ago
            when "year"
                @start_date = 1.year.ago
        end
        if @time != "all"
            @jobs = @jobs.where("jobs.start_date > :start_date AND jobs.start_date <= :end_date", start_date: @start_date, end_date: @end_date)
        end

        case @rating
            when "1"
                @jobs = @jobs.where("jobs.rating = 1")
            when "2"
                @jobs = @jobs.where("jobs.rating = 2")
            when "3"
                @jobs = @jobs.where("jobs.rating = 3")
            when "4"
                @jobs = @jobs.where("jobs.rating = 4")
            when "5"
                @jobs = @jobs.where("jobs.rating = 5")
        end

        case @failure_level
            when "0"
                @jobs = @jobs.where("failures_count = 0")
            when "1"
                @jobs = @jobs.where("failures_count = 1")
            when "2"
                @jobs = @jobs.where("failures_count = 2")
            when "3"
                @jobs = @jobs.where("failures_count >= 3")
        end

    end

end
