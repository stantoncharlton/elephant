class StaticPagesController < ApplicationController
    include JobAnalysisHelper
    before_filter :signed_in_user, only: [:help, :overview, :filter_overview, :terms_of_use]

    skip_before_filter :verify_traffic, only: [:home, :about, :sales, :terms_of_use]
    skip_before_filter :accept_terms_of_use, only: [:terms_of_use]
    skip_before_filter :session_expiry, only: [:home, :about, :sales]
    skip_before_filter :update_activity_time, only: [:home, :about, :sales]

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
        @district_id = params[:district_id]
        @division_id = params[:division_id]
        @user_id = params[:user_id]

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
            @jobs = @jobs.where("jobs.id IN (?)", @user.jobs.map { |j| j.id }.uniq)
            @user_name = @user.name
        end
    end

    def analyze
        @personnel_utilization = personnel_utilization(@jobs)
        @total_personnel = total_personnel(@jobs)
        @total_districts = total_districts(@jobs)
        @total_job_types = total_job_types(@jobs)
        @average_job_time = average_job_duration(@jobs)
        @job_failure_rate = job_failure_rate(@jobs)
        @failures = failures(@jobs)
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
