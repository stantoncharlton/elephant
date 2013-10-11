class IssuesController < ApplicationController
    before_filter :signed_in_user, only: [:index, :show, :update]

    def index
        @issues = Issue.where(:company_id => current_user.company).order("issues.status ASC, issues.created_at DESC")
        if current_user.district.present?
            @issues = @issues.includes(:job).where("jobs.district_id IN (SELECT id FROM districts where master_district_id = :district_id)", district_id: current_user.district.master_district_id)
        end

        @issues = @issues.paginate(page: params[:page], limit: 20)
        @failures_current_year = Failure.where(:company_id => current_user.company_id).where(:template => false).where("failures.job_id IS NOT NULL").where("failures.created_at >= '#{ Time.now.year }/1/1'").select("date_trunc('month', failures.created_at) as DATE").group("date_trunc('month', failures.created_at)").count("failures.created_at").map {|k,v| {Date.strptime(k).month => v}  }.reduce(:merge)
    end

    def show
        @issue = Issue.find_by_id(params[:id])
        not_found unless @issue.company == current_user.company
    end

    def update
        @issue = Issue.find_by_id(params[:id])
        not_found unless @issue.company == current_user.company

        if params[:closed] == "true"
            @issue.update_attribute(:status, Issue::CLOSED)
        end
    end

end
