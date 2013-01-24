class SettingsController < ApplicationController
    before_filter :signed_in_user, only: [:edit, :update]

    def edit
        @user = current_user
    end

    def update

        @user = User.find_by_id(params[:id])
        not_found unless @user.company == current_user.company

        User.transaction do
            @user.update_attribute(:language, params[:user][:language])
            @user.update_attribute(:time_zone, params[:user][:time_zone])

            flash[:success] = "Settings updated"
            render "edit"
        end
    end

end
