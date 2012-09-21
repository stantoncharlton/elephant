class UsersController < ApplicationController
    before_filter :signed_in_user, only: [:show, :settings]
    before_filter :company_admin, only: [:settings, :new, :create]
    before_filter :current_company, only: [:show, :create]


    def settings
        @user = current_user
    end

    def show
        @user = User.find(params[:id])
    end

    def new
        @user = User.new
    end

    def create
        company_id = params[:user][:company]
        params[:user].delete(:company)

        @user = User.new(params[:user])
        @user.company = Company.find_by_id(company_id)
        @user.password = "foobar"
        @user.password_confirmation = "foobar"
        if @user.save
            flash[:success] = "User created"
            redirect_back_or company_path

        else
            render 'new'
        end
    end

    private

    def signed_in_user
        unless signed_in?
            store_location
            redirect_to signin_url, notice: "Please sign in."
        end
    end

    def current_company
        if (params[:company].present?)
            redirect_to(root_path) unless current_user.company.id == params[:company] || current_user.elephant_admin?
        elsif (params[:id].present?)
            redirect_to(root_path) unless current_user.company == User.find(params[:id]).company || current_user.elephant_admin?
        end

    end


    def company_admin
        redirect_to(root_path) unless signed_in? && (current_user.admin? &&
                current_user.company == User.find(params[:id]).company) || current_user.elephant_admin?
    end
end
