class ApplicationController < ActionController::Base
    protect_from_forgery
    include SessionsHelper

    before_filter :set_current_user_for_observer
    #before_filter :set_time_zone

    def set_current_user_for_observer
        UserObserver.current_user = current_user
    end

    def set_time_zone
        Time.zone = "Central Time (US & Canada)"
    end


    def signed_in_user
        unless signed_in?
            store_location
            redirect_to signin_url, notice: "Please sign in."
        end
    end

    def signed_in_admin
        unless signed_in_admin?
            store_location
            redirect_to signin_url, notice: "Please sign in."
        end
    end

    def not_found
        raise ActionController::RoutingError.new('Not Found')
    end
end
