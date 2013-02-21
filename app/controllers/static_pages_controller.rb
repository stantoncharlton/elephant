class StaticPagesController < ApplicationController
    before_filter :signed_in_user, only: [:help, :overview, :terms_of_use]

    skip_before_filter :accept_terms_of_use, only: [:terms_of_use]
    skip_before_filter :session_expiry, only: [:home, :about, :sales]
    skip_before_filter :update_activity_time, only: [:home, :about, :sales]

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

    def about
    end

    def sales
    end

    def overview
        set_tab :overview

    end

    def terms_of_use
        if params[:accept].present?
            if params[:accept] == "true"
                current_user.update_attribute(:accepted_tou, true)
                redirect_to root_url
            elsif params[:accept] == "false"
                sign_out
                redirect_to root_url
            end
        end
    end
end
