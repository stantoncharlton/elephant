class StaticPagesController < ApplicationController
    def home
        redirect_to users_path if signed_in_admin?
    end

    def help
    end

    def about
    end

    def sales
    end
end
