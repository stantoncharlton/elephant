class WarehousesController < ApplicationController
    before_filter :signed_in_user_inventory, only: [:show, :new, :create, :destroy]
    set_tab :inventory

    def show

    end

    def new
        @warehouse = Warehouse.new

        @district = District.find_by_id(params[:district])
        not_found unless @district.company == current_user.company
    end

    def create

    end

    def destroy

    end

end
