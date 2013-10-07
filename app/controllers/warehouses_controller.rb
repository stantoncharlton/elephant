class WarehousesController < ApplicationController
    before_filter :signed_in_user_inventory, only: [:show, :new, :create, :destroy]
    set_tab :inventory

    def show
        @warehouse = Warehouse.find_by_id(params[:id])
        not_found unless @warehouse.company == current_user.company

        @parts = Part.includes(:parts).where(:company_id => current_user.company_id).where(:warehouse_id => @warehouse.id).where(:template => true).order("parts.name ASC").paginate(page: params[:page], limit: 30)
    end

    def new
        @warehouse = Warehouse.new

        @district = District.find_by_id(params[:district])
        not_found unless @district.company == current_user.company
    end

    def create
        district_id = params[:warehouse][:district]
        params[:warehouse].delete(:district)
        @district = District.find_by_id(district_id)
        not_found unless @district.company == current_user.company

        @warehouse = Warehouse.new(params[:warehouse])
        @warehouse.company = current_user.company
        @warehouse.district = @district

        if @warehouse.save
            redirect_to @warehouse
        else
            render 'new'
        end
    end

    def destroy

    end

end
