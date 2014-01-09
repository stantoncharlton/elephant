class ApplicationController < ActionController::Base
    protect_from_forgery
    include SessionsHelper
    include VpnHelper


    before_filter :session_expiry
    before_filter :update_session_expiration

    before_filter :verify_traffic

    before_filter :set_current_user_for_observer
    before_filter :set_user_time_zone
    before_filter :set_locale


    before_filter :accept_terms_of_use

    set_current_tenant_through_filter
    before_filter :set_tenant


    def session_expiry
        #if !request.headers['x-access-token'].blank? && current_user

        #else
        get_session_time_left
        #end
    end

    private

    def get_session_time_left
        expire_time = session[:expires_at] || Time.now
        @session_time_left = (expire_time - Time.now).to_i

        unless @session_time_left > 0
            sign_out
            deny_access
        end
    end

    def accept_terms_of_use
        if signed_in? and !current_user.accepted_tou?
            redirect_to terms_of_use_path
        end
    end


    def set_current_user_for_observer
        UserObserver.current_user = current_user
    end


    def set_tenant
        if current_user.present?
            set_current_tenant(current_user.company)
            # For Shared drilling log
        elsif request.path == drilling_logs_path &&
                cookies[:share].present? &&
                cookies[:access_code].present? &&
                cookies[:email].present?
            @document_share = DocumentShare.find_by_id(cookies[:share])
            if @document_share.access_code == cookies[:access_code] && @document_share.email == cookies[:email]
                set_current_tenant(@document_share.company)
            end
        end
    end


    def signed_in_user
        unless signed_in?
            store_location
            redirect_to signin_url, error: "Please sign in."
        end
    end

    def signed_in_user_inventory
        unless signed_in? && current_user.role.access_to_inventory?
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
        if signed_in?
            Time.zone = current_user.present? && current_user.time_zone.present? ? current_user.time_zone : "Central Time (US & Canada)"
        else
            Time.zone = "Central Time (US & Canada)"
        end
    end

    def set_locale
        I18n.locale = params[:locale] if params[:locale].present?
        # current_user.locale
        # request.subdomain
        # request.env["HTTP_ACCEPT_LANGUAGE"]
        # request.remote_ip
    end

end
