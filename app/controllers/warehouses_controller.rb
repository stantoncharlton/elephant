class WarehousesController < ApplicationController
    before_filter :signed_in_user_inventory, only: [:show, :new, :create, :destroy]
    set_tab :inventory

    include InventoryHelper


    def show
        @warehouse = Warehouse.find_by_id(params[:id])
        not_found unless @warehouse.present? && @warehouse.company == current_user.company

        if current_user.role.limit_to_assigned_jobs?
            if current_user.warehouses.find { |w| w.id == @warehouse.id} == nil
                not_found
            end
        end

        @condensed = true

        respond_to do |format|
            format.html {
                @parts = Part.includes(:parts).where(:company_id => current_user.company_id).where(:warehouse_id => @warehouse.id).where(:template => true).order("parts.name ASC").paginate(page: params[:page], limit: 30)
            }
            format.xlsx {
                @parts = Part.includes(:parts).where(:company_id => current_user.company_id).where(:warehouse_id => @warehouse.id).where(:template => true).order("parts.name ASC")
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
            redirect_to @warehouse
        else
            render 'new'
        end
    end

    def destroy

    end

end
