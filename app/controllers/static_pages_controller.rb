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
        @personnel_utilization = personnel_utilization(@jobs)
        @average_job_time = average_job_duration(@jobs)
        @job_failure_rate = job_failure_rate(@jobs)

        @failures = failures(@jobs)
    end

    def filter_overview
        set_tab :overview

        @district_id = params[:district_id]
        @division_id = params[:division_id]
        @user_id = params[:user_id]

        @jobs = Job.from_company(current_user.company)
        if !@district_id.blank?
            @jobs = @jobs.where(district_id: @district_id)
            @district_name = District.find_by_id(@district_id).name
        end

        if !@division_id.blank?
            parts = @division_id.split("/////")
            name = ""
            case parts.first.downcase
                when "division"
                    name = Division.find_by_id(parts.last).name
                    @jobs = @jobs.joins(job_template: {product_line: {segment: :division}}).where("divisions.id = ?", parts.last)
                when "segment"
                    name = Segment.find_by_id(parts.last).name
                    @jobs = @jobs.joins(job_template: {product_line: :segment}).where("segments.id = ?", parts.last)
                when "product line"
                    name = ProductLine.find_by_id(parts.last).name
                    @jobs = @jobs.joins(job_template: :product_line).where("product_lines.id = ?", parts.last)
                when "job template"
                    name = JobTemplate.find_by_id(parts.last).name
                    @jobs = @jobs.joins(:job_template).where("job_templates.id = ?", parts.last)
            end
            @division_name = name
        end

        if !@user_id.blank?
            @user = User.find_by_id(@user_id)
            not_found unless @user.company == current_user.company
            @jobs = @user.jobs
            @user_name = @user.name

            @division_id = nil
            @district_id = nil
            @division_name = nil
        end

        @personnel_utilization = personnel_utilization(@jobs)
        @average_job_time = average_job_duration(@jobs)
        @job_failure_rate = job_failure_rate(@jobs)

        @failures = failures(@jobs)

        render 'overview'
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
