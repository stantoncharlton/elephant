class AlertsController < ApplicationController
    before_filter :signed_in_user, only: [:index]

    set_tab :alerts


    def index
        @alerts = []
    end
end
