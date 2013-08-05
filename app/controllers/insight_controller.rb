class InsightController < ApplicationController
    before_filter :signed_in_user, only: [:index]
    set_tab :insight

    def index
        @failures = Failure.where("company_id = ?", current_user.company_id).where("failures.template IS FALSE").where("failures.created_at >= ?", 4.weeks.ago).order("failures.created_at DESC").paginate(page: params[:page], limit: 30)

        @failures_current_year = Failure.where(:company_id => current_user.company_id).where(:template => false).where("failures.created_at >= '#{ Time.now.year }/1/1'").select(:created_at).group_by{ |u| u.created_at.month }.map { |k,v| {k => v.count} }.reduce(:merge)
        @failures_last_year = Failure.where(:company_id => current_user.company_id).where(:template => false).where("failures.created_at >= '1/1/#{ Time.now.year - 1 }' AND failures.created_at <= '12/31/#{ Time.now.year - 1 }'").select(:created_at).group_by{ |u| u.created_at.month }.map { |k,v| {k => v.count} }.reduce(:merge)

    end

end
