class StaticPagesController < ApplicationController
    before_filter :signed_in_user, only: [:help, :terms_of_use, :tutorial]

    skip_before_filter :verify_traffic, only: [:home, :features, :about, :sales, :terms_of_use]
    skip_before_filter :accept_terms_of_use, only: [:terms_of_use]
    skip_before_filter :session_expiry, only: [:home, :features, :about, :sales]
    skip_before_filter :update_activity_time, only: [:home, :features, :about, :sales]

    caches_action :home
    caches_action :help
    caches_action :features
    caches_action :about
    caches_action :sales
    caches_action :terms_of_use
    caches_action :tutorial

    def home
        respond_to do |format|
            format.html {
                if signed_in_admin?
                    redirect_to users_path
                elsif signed_in?
                    if current_user.alerts.any?
                        redirect_to alerts_path
                    else
                        redirect_to jobs_path
                    end
                end
            }
            format.xml {
                if signed_in?
                    render :nothing => true, :status => :ok
                else
                    render :nothing => true, :status => :unauthorized
                end
            }
        end
    end

    def help
    end

    def features
        set_tab :features
    end

    def about
        set_tab :about
    end

    def sales
        set_tab :sales
    end

    def terms_of_use
        if params[:accept].present?
            if params[:accept] == "true"
                current_user.update_attribute(:accepted_tou, true)
                redirect_to tutorial_path
            elsif params[:accept] == "false"
                sign_out
                redirect_to root_url
            end
        end
    end

    def tutorial

    end
end
