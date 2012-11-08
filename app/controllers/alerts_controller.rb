class AlertsController < ApplicationController
    before_filter :signed_in_user, only: [:index]

    set_tab :alerts

    def index
        @alerts = current_user.alerts.paginate(page: params[:page], limit: 10)
    end
end
