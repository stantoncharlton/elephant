class ShipmentsController < ApplicationController
    before_filter :signed_in_user, only: [:index, :new, :show, :create, :edit, :update, :destroy]

    def index

    end


    def show
        @shipment = Shipment.find_by_id(params[:id])
        not_found unless @shipment.present?
    end

    def new
        @shipment = Shipment.new
    end

    def create
        @shipment = Shipment.new()
        if params[:district]
            @shipment.district = District.find_by_id(params[:district])
        end
        if params[:job]
            @shipment.from = Job.find_by_id(params[:job])
            @shipment.from_name = @shipment.from.present? ? (@shipment.from.well.rig.present? ? @shipment.from.well.rig.name + " - " : "") + @shipment.from.field.name + " | " + @shipment.from.well.name : ""
            @shipment.from_editable = false
        else
            @shipment.from_name = ""
            @shipment.from_editable = true
        end
        @shipment.to_name = ""
        @shipment.company = current_user.company
        @shipment.user = current_user
        @shipment.status = Shipment::AWAITING_SHIPMENT
        @shipment.save
    end

    def edit
        @shipment = Shipment.find_by_id(params[:id])
    end

    def update
        Shipment.transaction do
            @shipment = Shipment.find_by_id(params[:id])

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

            if !@shipment.from_editable
                @shipment.part_memberships.each do |pm|
                    pm.destroy
                end
                if params[:pm].present?
                    params[:pm].each do |k, v|
                        if v == "true"
                            key = k.gsub("pm_", "")
                            pm = PartMembership.find_by_id(key)
                            part_membership = pm.duplicate
                            part_membership.job = nil
                            part_membership.shipment = @shipment
                            part_membership.save
                        end
                    end
                end
            end

            @shipment.status = Shipment::IN_TRANSIT
            @shipment.save

            @shipment = Shipment.find_by_id(@shipment.id)
        end
    end

    def destroy
        @shipment = Shipment.find(params[:id])
        @shipment.destroy
    end


end
