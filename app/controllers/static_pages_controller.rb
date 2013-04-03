class StaticPagesController < ApplicationController
    include JobAnalysisHelper
    before_filter :signed_in_user, only: [:help, :overview, :filter_overview, :terms_of_use]

    skip_before_filter :verify_traffic, only: [:home, :features, :about, :sales, :terms_of_use]
    skip_before_filter :accept_terms_of_use, only: [:terms_of_use]
    skip_before_filter :session_expiry, only: [:home, :features, :about, :sales]
    skip_before_filter :update_activity_time, only: [:home, :features, :about, :sales]

    def home
        respond_to do |format|
            format.html {
                if signed_in_admin?
                    redirect_to users_path
                elsif signed_in?
                    if current_user.alerts.any?
                        redirect_to alerts_path
                    else
                        redirect_to jobs_path
                    end
                end
            }
            format.xml {
                if signed_in?
                    render :nothing => true, :status => :ok
                else
                    render :nothing => true, :status => :unauthorized
                end
            }
        end
    end

    def help
    end

    def features
    end

    def about
    end

    def sales
    end

    def overview
        set_tab :overview

        @jobs = Job.from_company(current_user.company)

        filter
        analyze

        @jobs = @jobs.reorder('').order("jobs.created_at DESC").paginate(page: params[:page], limit: 10)

        render 'overview'
    end

    def filter_overview
        set_tab :overview

        @jobs = Job.from_company(current_user.company)

        filter
        analyze

        @jobs = @jobs.reorder('').order("jobs.created_at DESC").paginate(page: params[:page], limit: 10)

        render 'overview'
    end

    def filter

        if current_user.role.limit_to_assigned_jobs?
            @jobs = @jobs.where("jobs.id IN (SELECT job_id FROM job_memberships where user_id = :user_id)", user_id: current_user.id)
        elsif current_user.role.limit_to_district?
            @jobs = @jobs.where(:district_id => current_user.district.id)
        elsif current_user.role.limit_to_product_line? && !current_user.product_line.nil?
            @jobs = @jobs.joins(:job_template).where("job_templates.product_line_id = :product_line_id OR jobs.district_id = :district_id", product_line_id: current_user.product_line.id, district_id: current_user.district.id)
        end

        @district_id = params[:district_id]
        @division_id = params[:division_id]
        @user_id = params[:user_id]
        @time = params[:time].blank? ? "all" : params[:time]
        @rating = params[:rating].blank? ? "all" : params[:rating]
        @failure_level = params[:failure_level].blank? ? "all" : params[:failure_level]
        @filters_open = params[:filters_open].blank? ? "" : params[:filters_open]

        if !@district_id.blank?
            @jobs = @jobs.where(district_id: @district_id)
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
        @end_date = Time.now
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
        @jobs = @jobs.where("jobs.start_date > :start_date AND jobs.start_date <= :end_date", start_date: @start_date, end_date: @end_date)

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
            when "1"
                @jobs = @jobs.where("failures_count = 1")
            when "2"
                @jobs = @jobs.where("failures_count = 2")
            when "3"
                @jobs = @jobs.where("failures_count >= 3")
        end

    end

    def analyze
        @personnel_utilization = personnel_utilization(@jobs)
        @total_personnel = total_personnel(@jobs)
        @total_districts = total_districts(@jobs)
        @total_job_types = total_job_types(@jobs)
        @average_job_time = average_job_duration(@jobs)
        @average_job_performance = average_job_performance(@jobs)
        @job_success_rate = 100 - job_failure_rate(@jobs)

        @failures = failures(@jobs)
        @failures_list = @failures.take(4).to_a
        @failures_count = @failures.count()
    end

    def terms_of_use
        if params[:accept].present?
            if params[:accept] == "true"
                current_user.update_attribute(:accepted_tou, true)
                redirect_to root_url
            elsif params[:accept] == "false"
                sign_out
                redirect_to root_url
            end
        end
    end
end
