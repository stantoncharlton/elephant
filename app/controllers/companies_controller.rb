class CompaniesController < ApplicationController
    before_filter :elephant_admin_user, only: [:new, :destroy, :create]
    before_filter :signed_in_user, only: [:show]
    before_filter :signed_in_admin, only: [:edit, :update]

    def show
        @company = current_user.company
        @users = User.from_company(@company).includes(:district, :company).paginate(page: params[:page], limit: 20)
    end

    def new
        @company = Company.new
    end

    def destroy
        Company.find_by_id(params[:id]).destroy
        flash[:success] = "Company destroyed."
        redirect_to elephant_admin_path
    end

    def create
        @company = Company.new(params[:company])
        if @company.save
            flash[:success] = "Company created"
            redirect_to elephant_admin_path
        else
            render 'new'
        end
    end

    def edit
        @company = Company.find_by_id(params[:id])
    end

    def update
        @company = Company.find_by_id(params[:id])
        not_found unless @company == current_user.company

        if @company.update_attributes(params[:company])
            flash[:success] = "Company updated"
            redirect_to edit_company_path
        else
            render 'edit'
        end
    end


    private

    def elephant_admin_user
        redirect_to root_path unless signed_in? && current_user.elephant_admin?
    end
end
