class StaticPagesController < ApplicationController
    def home
        if signed_in_admin?
            redirect_to users_path
        elsif signed_in?
            redirect_to jobs_path
        end
    end

    def help
    end

    def about
    end

    def sales
    end
end
