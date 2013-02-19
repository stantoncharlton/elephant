class ApplicationController < ActionController::Base
    protect_from_forgery
    include SessionsHelper

    before_filter :session_expiry
    before_filter :update_activity_time

    before_filter :set_user_time_zone
    before_filter :set_locale
    before_filter :set_current_user_for_observer
    #before_filter :set_time_zone


    def session_expiry
        get_session_time_left
        unless @session_time_left > 0
            store_location
            sign_out
            redirect_to root_path, error: "Your session has timed out. Please sign in."
        end
    end

    def update_activity_time
        session[:expires_at] = 20.minutes.from_now
    end

    private

    def get_session_time_left
        expire_time = session[:expires_at] || Time.now
        @session_time_left = (expire_time - Time.now).to_i
    end


    def set_current_user_for_observer
        puts request.path
        UserObserver.current_user = current_user
    end


    def signed_in_user
        unless signed_in?
            store_location
            redirect_to signin_url, error: "Please sign in."
        end
    end

    def signed_in_admin
        unless signed_in_admin?
            store_location
            redirect_to signin_url, error: "Please sign in."
        end
    end

    def not_found
        raise ActionController::RoutingError.new('Not Found')
    end

private

    def set_user_time_zone
        Time.zone = current_user.time_zone.present? ? current_user.time_zone : "Central Time (US & Canada)" if signed_in?
    end

    def set_locale
        puts  request.env["HTTP_ACCEPT_LANGUAGE"]
        I18n.locale = params[:locale] if params[:locale].present?
        # current_user.locale
        # request.subdomain
        # request.env["HTTP_ACCEPT_LANGUAGE"]
        # request.remote_ip
    end

end
