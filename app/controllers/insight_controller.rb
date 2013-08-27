class InsightController < ApplicationController
    before_filter :signed_in_user, only: [:index]
    set_tab :insight

    def index
        @failures = Failure.where("company_id = ?", current_user.company_id).where("failures.template IS FALSE").where("failures.created_at >= ?", 4.weeks.ago).order("failures.created_at DESC").paginate(page: params[:page], limit: 30)

        @failures_current_year = Failure.where(:company_id => current_user.company_id).where(:template => false).where("failures.created_at >= '#{ Time.now.year }/1/1'").select("date_trunc('month', failures.created_at) as DATE").group("date_trunc('month', failures.created_at)").count("failures.created_at").map {|k,v| {Date.strptime(k).month => v}  }.reduce(:merge)
        @failures_last_year = Failure.where(:company_id => current_user.company_id).where(:template => false).where("failures.created_at >= '1/1/#{ Time.now.year - 1 }' AND failures.created_at <= '12/31/#{ Time.now.year - 1 }'").select("date_trunc('month', failures.created_at) as DATE").group("date_trunc('month', failures.created_at)").count("failures.created_at").map {|k,v| {Date.strptime(k).month => v}  }.reduce(:merge)

    end

end
