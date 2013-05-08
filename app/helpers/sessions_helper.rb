module SessionsHelper

    def sign_in(user, permanent)
        if permanent
            cookies.permanent[:remember_token] = user.remember_token
        else
            cookies[:remember_token] = user.remember_token
        end

        update_session_expiration
        self.current_user = user
    end

    def signed_in?
        !current_user.nil?
    end

    def signed_in_admin?
        !current_user.nil? && (current_user.admin? || current_user.elephant_admin?)
    end

    def current_user=(user)
        @current_user = user
    end

    def current_user
        if @current_user
            @current_user
        else
            @current_user ||= User.find_by_remember_token(cookies[:remember_token])
            if @current_user.nil? && !request.headers['x-access-token'].blank?
                api_key = ApiKey.find_by_access_token(request.headers['x-access-token'])
                if api_key.present? && api_key.user_id == request.headers['x-user'].to_i
                    @api_request = true
                    @current_user ||= api_key.user
                    self.current_user = @current_user
                    return @current_user
                end
            end
        end
    end

    def current_user?(user)
        user == current_user
    end

    def sign_out
        session[:return_to] = nil
        self.current_user = nil
        cookies.delete(:remember_token)
    end

    def update_session_expiration
        session[:expires_at] = 2.hours.from_now
    end

    def deny_access(msg = nil)
        msg ||= "Session has expired. Please sign in."
        flash[:error] ||= msg
        respond_to do |format|
            format.html {
                store_location
                redirect_to root_url
            }
            format.js {
                store_last_location
                render 'sessions/redirect_to_login', :layout => false
            }
        end
    end


    def signed_in_user
        unless signed_in?
            store_location
            redirect_to root_url, notice: "Please sign in."
        end
    end


    def redirect_back_or(default)
        redirect_to(session[:return_to] || default)
        session.delete(:return_to)
    end

    def store_location
        session[:return_to] = request.url
    end

    def store_last_location
        session[:return_to] = request.referer
    end

end
