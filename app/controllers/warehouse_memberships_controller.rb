class WarehouseMembershipsController < ApplicationController
    before_filter :signed_in_user, only: [:new, :create, :edit, :update, :destroy]

    def new
        @warehouse_membership = WarehouseMembership.new
    end

    def create
        warehouse_id = params[:warehouse_membership][:warehouse_id]
        params[:warehouse_membership].delete(:warehouse_id)

        user_id = params[:warehouse_membership][:user_id]
        params[:warehouse_membership].delete(:user_id)

        @warehouse = Warehouse.find_by_id(warehouse_id)
        not_found unless @warehouse.company == current_user.company

        @user = User.find_by_id(user_id)

        @warehouse_membership = WarehouseMembership.new(params[:job_membership])
        @warehouse_membership.user = @user
        @warehouse_membership.warehouse = @warehouse
        @warehouse_membership.company = current_user.company
        @warehouse_membership.save
    end

    def destroy
        @warehouse_membership = WarehouseMembership.find_by_id(params[:id])
        not_found unless @warehouse_membership.company == current_user.company

        @warehouse_membership.destroy
    end
end
