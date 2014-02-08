class ShipperController < ApplicationController
    before_filter :signed_in_user_inventory, only: [:show, :new, :create, :edit, :update, :destroy]
    set_tab :inventory


    def show
        @shipper = Shipper.find_by_id(params[:id])
        not_found unless @shipper.present?
    end

    def new
        @shipper = Shipper.new

        @district = District.find_by_id(params[:district])
        not_found unless @district.company == current_user.company
    end

    def create
        district_id = params[:shipper][:district]
        params[:shipper].delete(:district)
        @district = District.find_by_id(district_id)
        not_found unless @district.company == current_user.company

        @shipper = Shipper.new(params[:shipper])
        @shipper.company = current_user.company
        @shipper.district = @district

        if @shipper.save
            redirect_to inventory_path(@shipper.district_id, anchor: "shippers")
        else
            render 'new'
        end
    end

    def edit
        @shipper = Shipper.find_by_id(params[:id])
        not_found unless @shipper.present?
    end

    def update
        @shipper = Shipper.find_by_id(params[:id])
        @shipper.update_attributes(params[:shipper])

        redirect_to @shipper
    end

    def destroy
        @shipper = Shipper.find_by_id(params[:id])
        @shipper.destroy
        redirect_to inventory_path(@shipper.district_id, anchor: "shipper")
    end


end
