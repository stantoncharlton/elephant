class InsightController < ApplicationController
    before_filter :signed_in_user, only: [:index]
    set_tab :insight

    def index
        @failures = Failure.where("company_id = ?", current_user.company_id).where("failures.template IS FALSE").where("failures.created_at >= ?", 4.weeks.ago).order("failures.created_at DESC").paginate(page: params[:page], limit: 30)
    end

end
