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
        @editable = params[:editable] == 'true'
    end

    def update
        Shipment.transaction do
            @shipment = Shipment.find_by_id(params[:id])
            not_found unless @shipment.present?

            if @shipment.status == Shipment::COMPLETE
                return
            end

            if params[:update_field].present? && params[:update_field] == "true" &&
                    params[:field].present? && params[:value].present?
                case params[:field]
                    when "receive_shipment"
                        @shipment = Shipment.find_by_id(params[:value])
                        @shipment.receive_shipment current_user
                end
            else

                if params[:shipment].present?
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
                            @shipment.to_name = @shipment.to.present? ? @shipment.to.name : ""
                        when Supplier.name
                            @shipment.to = Supplier.find_by_id(params[:to_id_supplier])
                            @shipment.to_name = @shipment.to.present? ? @shipment.to.name : ""
                        when Job.name
                            @shipment.to = Job.find_by_id(params[:to_id_job])
                            @shipment.to_name = @shipment.to.present? ? (@shipment.to.well.rig.present? ? @shipment.to.well.rig.name + " - " : "") + @shipment.to.field.name + " | " + @shipment.to.well.name : ""
                    end
                end

                if !@shipment.from_editable
                    @shipment.part_memberships.each do |pm|
                        if pm.job_part_membership.present?
                            pm.job_part_membership.update_attribute(:shipping, false)
                        end
                        pm.destroy
                        if pm.part_type == PartMembership::INVENTORY && pm.part.present?
                            pm.part.removed false
                        end
                    end
                    if params[:pm].present?
                        params[:pm].each do |k, v|
                            if v == "true"
                                key = k.gsub("pm_", "")
                                pm = PartMembership.find_by_id(key)
                                part_membership = pm.duplicate
                                part_membership.job_part_membership = pm
                                part_membership.job = nil
                                part_membership.shipment = @shipment
                                part_membership.save
                                pm.update_attribute(:shipping, true)
                                if part_membership.part_type == PartMembership::INVENTORY && part_membership.part.present?
                                    part_membership.part.asset_shipping @shipment
                                end
                            end
                        end
                    end
                end

                @shipment.status = Shipment::IN_TRANSIT
                @shipment.save

                @shipment = Shipment.find_by_id(@shipment.id)
            end
        end
    end

    def destroy
        @shipment = Shipment.find(params[:id])
        @shipment.destroy
    end


end
