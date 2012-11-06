class AlertsController < ApplicationController
        set_tab :alerts


        def index
            @alerts = []
        end
end
