class HistoryController < ApplicationController
    before_filter :signed_in_user, only: [:index]

    set_tab :history


    def index
        @activities = []

        current_user.jobs.each do |job|
            Activity.activities_for_job(job).each do |activity|
                @activities << activity
            end
        end
    end

end
