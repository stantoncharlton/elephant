class CompaniesController < ApplicationController
    before_filter :elephant_admin_user, only: [:new, :destroy, :create]
    before_filter :signed_in_user, only: [:show]

    def show
        store_location

        if current_user.elephant_admin? && request.path != company_path
              @company = Company.find(params[:id])
              @users = User.find_all_by_company_id(@company.id)
        else
            if params[:id].present? && params[:id] != current_user.company.id.to_s
               redirect_to company_path
            else
                @company = current_user.company
                @users = User.find_all_by_company_id(@company.id)
            end
        end
    end

    def new
        @company = Company.new
    end

    def destroy
        Company.find(params[:id]).destroy
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


private

    def elephant_admin_user
        redirect_to root_path unless signed_in? && current_user.elephant_admin?
    end
end
