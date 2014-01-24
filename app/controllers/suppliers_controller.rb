class SuppliersController < ApplicationController
    before_filter :signed_in_user_inventory, only: [:show, :new, :create, :edit, :update, :destroy]
    set_tab :inventory


    def show
        @supplier = Supplier.find_by_id(params[:id])
        not_found unless @supplier.present?
    end

    def new
        @supplier = Supplier.new

        @district = District.find_by_id(params[:district])
        not_found unless @district.company == current_user.company
    end

    def create
        district_id = params[:supplier][:district]
        params[:supplier].delete(:district)
        @district = District.find_by_id(district_id)
        not_found unless @district.company == current_user.company

        @supplier = Supplier.new(params[:supplier])
        @supplier.company = current_user.company
        @supplier.district = @district

        if @supplier.save
            redirect_to inventory_path(@supplier.district_id, anchor: "suppliers")
        else
            render 'new'
        end
    end

    def edit
        @supplier = Supplier.find_by_id(params[:id])
        not_found unless @supplier.present?
    end

    def update
        @supplier = Supplier.find_by_id(params[:id])
        @warehouse.update_attributes(params[:supplier])

        redirect_to @supplier
    end

    def destroy
        @supplier = Supplier.find_by_id(params[:id])
        @supplier.destroy
        redirect_to inventory_path(@supplier.district_id, anchor: "suppliers")
    end


end
