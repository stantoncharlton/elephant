class ShippersController < ApplicationController
    before_filter :signed_in_user_inventory, only: [:show, :new, :create, :edit, :update, :destroy]
    set_tab :inventory

    def index
        if params[:district].present?
            @district = District.find_by_id(params[:district])
            not_found unless @district.company == current_user.company
        elsif current_user.district.present?
            @district = current_user.district
        elsif current_user.company.districts.where(:master => true).count == 1
            @district = current_user.company.districts.where(:master => true).first.districts.first
        else
            @district = nil
        end

        @shippers = Shipper.where(:district_id => @district.id)
    end

    def show
        @shipper = Shipper.find_by_id(params[:id])
        not_found unless @shipper.present?
    end

    def new
        @shipper = Shipper.new

        @district = District.find_by_id(params[:district])
        not_found unless @district.present?
    end

    def create
        district_id = params[:shipper][:district]
        params[:shipper].delete(:district)
        @district = District.find_by_id(district_id)
        not_found unless @district.present?

        @shipper = Shipper.new(params[:shipper])
        @shipper.company = current_user.company
        @shipper.district = @district

        if @shipper.save
            flash[:success] = "Shipper created"
            redirect_to shippers_path(district: @shipper.district)
        else
            flash[:error] = @shipper.errors.full_messages.join(', ').html_safe
            render 'new'
        end
    end

    def edit
        @shipper = Shipper.find_by_id(params[:id])
        not_found unless @shipper.present?
    end

    def update
        @shipper = Shipper.find_by_id(params[:id])
        if @shipper.update_attributes(params[:shipper])
            flash[:success] = "Shipper updated"
            redirect_to @shipper
        else
            flash[:error] = @shipper.errors.full_messages.join(', ').html_safe
            render 'edit'
        end
    end

    def destroy
        @shipper = Shipper.find_by_id(params[:id])
        @shipper.destroy
        redirect_to inventory_path(@shipper.district_id, anchor: "shipper")
    end


end
