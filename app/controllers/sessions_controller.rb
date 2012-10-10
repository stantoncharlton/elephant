class SessionsController < ApplicationController

    def create

        user = User.find_by_email(params[:session][:email].downcase)
        if user && user.authenticate(params[:session][:password])
            if user.create_password?
                redirect_to update_password_path(email: user.email), :flash => { :error => "Please create a password" }
            else
                sign_in user
                redirect_to root_path
            end
        else
            redirect_to root_path, :flash => { :error => "Invalid email/password combination" }
        end
    end

    def destroy
        sign_out
        redirect_to root_url
    end

    def edit

    end

    def update
        current_password = params[:session][:current_password]
        params[:session].delete(:current_password)

        user = User.find_by_email(params[:session][:email].downcase)
        if user && user.authenticate(current_password)
            user.password = params[:session][:password]
            user.password_confirmation = params[:session][:password_confirmation]
            user.create_password = false
            if user.save
                flash[:success] = "Password updated"
                sign_in user
                redirect_to root_path
            else
                redirect_to update_password_path(email: user.email), :flash => { :error => "Passwords do not match" }
            end
        else
            render "edit", :flash => { :error => "Invalid email/password combination" }
        end
    end

end
