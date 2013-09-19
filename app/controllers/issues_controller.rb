class IssuesController < ApplicationController
    before_filter :signed_in_user, only: [:show, :update]

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
