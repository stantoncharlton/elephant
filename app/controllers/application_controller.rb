class ApplicationController < ActionController::Base
    protect_from_forgery
    include SessionsHelper

    before_filter :set_user_time_zone
    before_filter :set_locale
    before_filter :set_current_user_for_observer
    #before_filter :set_time_zone

    def set_current_user_for_observer
        puts request.path
        UserObserver.current_user = current_user
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

private

    def set_user_time_zone
        Time.zone = "Central Time (US & Canada)" if signed_in?
    end

    def set_locale
        puts request.env["HTTP_ACCEPT_LANGUAGE"]
        I18n.locale = params[:locale] if params[:locale].present?
        # current_user.locale
        # request.subdomain
        # request.env["HTTP_ACCEPT_LANGUAGE"]
        # request.remote_ip
    end

end
