class UsersController < ApplicationController
    before_filter :signed_in_user, only: [:settings]
    before_filter :current_company, only: [:show]

    def settings
        @user = current_user
    end

    def show

    end

private

    def signed_in_user
        unless signed_in?
            store_location
            redirect_to signin_url, notice: "Please sign in."
        end
    end

    def current_company
        @user = User.find(params[:id])
        redirect_to(root_path) unless current_user.company_id == @user.company_id
    end
end
