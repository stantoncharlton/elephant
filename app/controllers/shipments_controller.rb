class ShipmentsController < ApplicationController
    before_filter :signed_in_user, only: [:index, :new, :show, :create, :edit, :update, :destroy]

    def index

    end


    def show
        @shipment = Shipment.find(params[:id])
        not_found unless @shipment.present?
    end

    def new
        @shipment = Shipment.new
    end

    def create
        @shipment = Shipment.new()
        if params[:district]
            @shipment.district = District.find(params[:district])
        end
        @shipment.company = current_user.company
        @shipment.user = current_user
        @shipment.from_name = ""
        @shipment.to_name = ""
        @shipment.status = 0
        @shipment.save
    end

    def edit
        @shipment = Shipment.find(params[:id])
    end

    def update
        @shipment = Shipment.find(params[:id])

        from_type = params[:shipment][:from_type]
        to_type = params[:shipment][:to_type]

        case from_type
            when Warehouse.name
                @shipment.from = Warehouse.find_by_id(params[:from_id_warehouse])
                @shipment.from_name = @shipment.from.present? ? @shipment.from.name : ""
            when Supplier.name
                @shipment.from = Supplier.find_by_id(params[:from_id_supplier])
                @shipment.from_name = @shipment.from.present? ? @shipment.from.name : ""
            when Job.name
                @shipment.from = Job.find_by_id(params[:from_id_job])
                @shipment.from_name = @shipment.from.present? ? (@shipment.from.well.rig.present? ? @shipment.from.well.rig.name + " - " : "") + @shipment.from.field.name + " | " + @shipment.from.well.name : ""
        end

        case to_type
            when Warehouse.name
                @shipment.to = Warehouse.find_by_id(params[:to_id_warehouse])
                @shipment.to_name = @shipment.to.present? ? @shipment.from.name : ""
            when Supplier.name
                @shipment.to = Supplier.find_by_id(params[:to_id_supplier])
                @shipment.to_name = @shipment.to.present? ? @shipment.from.name : ""
            when Job.name
                @shipment.to = Job.find_by_id(params[:to_id_job])
                @shipment.to_name = @shipment.to.present? ? (@shipment.to.well.rig.present? ? @shipment.to.well.rig.name + " - " : "") + @shipment.to.field.name + " | " + @shipment.to.well.name : ""
        end

        puts ".............."
        puts @shipment.from_name
        puts @shipment.to_name
        @shipment.status = Shipment::IN_TRANSIT
        @shipment.save
    end

    def destroy
        @shipment = Shipment.find(params[:id])
        @shipment.destroy
    end


end
