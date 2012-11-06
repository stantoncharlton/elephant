class HistoryController < ApplicationController
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
