class WarehousesController < ApplicationController
    before_filter :signed_in_user_inventory, only: [:show, :new, :create, :edit, :update, :destroy]
    set_tab :inventory

    include InventoryHelper


    def show
        @warehouse = Warehouse.find_by_id(params[:id])
        not_found unless @warehouse.present?

        if current_user.role.limit_to_assigned_jobs?
            if current_user.warehouses.find { |w| w.id == @warehouse.id} == nil
                not_found
            end
        end

        @condensed = true

        respond_to do |format|
            format.html {
                @parts = Part.includes(:parts).where(:warehouse_id => @warehouse.id).where(:template => false).where("parts.status = :available OR parts.status = :maintenance", available: Part::AVAILABLE, maintenance: Part::IN_REDRESS).order("parts.name ASC").paginate(page: params[:page], limit: 100)
            }
            format.xlsx {
                @parts = Part.includes(:parts).where(:warehouse_id => @warehouse.id).where(:template => false).where("parts.status = :available OR parts.status = :maintenance", available: Part::AVAILABLE, maintenance: Part::IN_REDRESS).order("parts.name ASC")
                excel = parts_to_excel @parts
                send_data excel.to_stream.read, :filename => "Inventory List.xlsx", :type => "application/vnd.openxmlformates-officedocument.spreadsheetml.sheet"
            }
        end
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
            redirect_to inventory_path(@warehouse.district_id, anchor: "warehouses")
        else
            render 'new'
        end
    end

    def edit
        @warehouse = Warehouse.find_by_id(params[:id])
        not_found unless @warehouse.present?
    end

    def update
        @warehouse = Warehouse.find_by_id(params[:id])
        @warehouse.update_attributes(params[:warehouse])

        redirect_to @warehouse
    end

    def destroy
        @warehouse = Warehouse.find_by_id(params[:id])
        @warehouse.destroy
        redirect_to inventory_path(@warehouse.district_id, anchor: "warehouses")
    end

end
