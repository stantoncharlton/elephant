class CompaniesController < ApplicationController
    before_filter :elephant_admin_user, only: [:new, :destroy, :create]
    before_filter :signed_in_user, only: [:show]

    def show
        @company = Company.find(current_user.company_id)
    end

    def new
        @company = Company.new
    end

    def destroy
        @company = Company.find(params[:id])

        Company.find(params[:id]).destroy
        flash[:success] = "Company destroyed."
        redirect_to companies_url
    end

    def create
        @company = Company.new(params[:company])
        if @company.save
            flash[:success] = "Company created"
            redirect_to companies_url
        else
            render 'new'
        end
    end


private

    def elephant_admin_user
        redirect_to(root_path) unless signed_in? && current_user.elephant_admin?
    end
end
