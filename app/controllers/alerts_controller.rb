class AlertsController < ApplicationController
    before_filter :signed_in_user, only: [:index]

    set_tab :alerts

    def index
        @alerts = current_user.alerts.where("alert_type != 3")

        @new_alerts = Array.new
        @old_alerts = Array.new

        @alerts.each do |alert|

            if alert.expiration.nil? or alert.expiration > 6.3.days.from_now
                @new_alerts << alert
            else
                @old_alerts << alert
            end

            alert.seen
        end

    end
end
