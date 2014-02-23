class PartMembershipsController < ApplicationController
    before_filter :signed_in_user, only: [:new, :create, :edit, :update, :destroy]

    def new
        @part_membership = PartMembership.new
    end

    def create
        if params[:part_membership][:job_id].present?
            job_id = params[:part_membership][:job_id]
            params[:part_membership].delete(:job_id)
        else
            shipment_id = params[:part_membership][:shipment_id]
            params[:part_membership].delete(:shipment_id)
        end

        from_type = params[:part_membership][:from_type]
        params[:part_membership].delete(:from_type)

        to_type = params[:part_membership][:to_type]
        params[:part_membership].delete(:to_type)

        part_id = params[:part_membership][:part_id]
        params[:part_membership].delete(:part_id)

        part_type = params[:part_membership][:part_type]
        params[:part_membership].delete(:part_type)

        @part_membership = PartMembership.new(params[:part_membership])
        @part_membership.company = current_user.company

        case part_type
            when 'inventory'
                @part_membership.part_type = PartMembership::INVENTORY
            when 'rental'
                @part_membership.part_type = PartMembership::RENTAL
                @part_membership.name = params["rental_name"]
                @part_membership.serial_number = params["rental_serial_number"]
                @part_membership.asset_type = params["rental_asset_type"]

                part = Part.new
                part.company = current_user.company
                part.template = false
                part.rental = true
                if params["rental_district_id"].present?
                    part.district = District.find_by_id(params["rental_district_id"])
                elsif !shipment_id.blank?
                    part.district = Shipment.find_by_id(shipment_id).district
                elsif !job_id.blank?
                    part.district = Job.find_by_id(job_id).district
                end
                part.asset_type = @part_membership.asset_type
                part.manufacturer = params["rental_manufacturer"]
                part.name = params["rental_name"]
                part.serial_number = params["rental_serial_number"]
                part.save
                @part_membership.part = part

            when 'accessory'
                @part_membership.part_type = PartMembership::SALEABLE
                @part_membership.name = params["accessory_name"]
                @part_membership.serial_number = params["accessory_serial_number"]
                @part_membership.asset_type = params["accessory_asset_type"]
        end

        case from_type
            when Warehouse.name
                @part_membership.from = Warehouse.find_by_id(params[:from_id_warehouse])
                @part_membership.from_name = @part_membership.from.present? ? @part_membership.from.name : ""
            when Supplier.name
                @part_membership.from = Supplier.find_by_id(params[:from_id_supplier])
                @part_membership.from_name = @part_membership.from.present? ? @part_membership.from.name : ""
                if @part_membership.part.present? && @part_membership.part.rental
                    @part_membership.part.supplier = @part_membership.from
                    @part_membership.part.save
                end
            when Job.name
                @part_membership.from = Job.find_by_id(params[:from_id_job])
                @part_membership.from_name = @part_membership.from.present? ? (@part_membership.from.well.rig.present? ? @part_membership.from.well.rig.name + " - " : "") + @part_membership.from.field.name + " | " + @part_membership.from.well.name : ""
        end

        case to_type
            when Warehouse.name
                @part_membership.to = Warehouse.find_by_id(params[:to_id_warehouse])
                @part_membership.to_name = @part_membership.to.present? ? @part_membership.to.name : ""
            when Supplier.name
                @part_membership.to = Supplier.find_by_id(params[:to_id_supplier])
                @part_membership.to_name = @part_membership.to.present? ? @part_membership.to.name : ""
            when Job.name
                @part_membership.to = Job.find_by_id(params[:to_id_job])
                @part_membership.to_name = @part_membership.to.present? ? (@part_membership.to.well.rig.present? ? @part_membership.to.well.rig.name + " - " : "") + @part_membership.to.field.name + " | " + @part_membership.to.well.name : ""
        end

        @part_membership.inner_diameter = BigDecimal(params[:id])
        @part_membership.outer_diameter = BigDecimal(params[:od])
        @part_membership.length = BigDecimal(params[:length])
        @part_membership.up = params[:up].to_i
        @part_membership.down = params[:down].to_i


        if !job_id.blank?
            @part_membership.job = Job.find_by_id(job_id)
            not_found unless @part_membership.job.present? && @part_membership.job.company == current_user.company
        else
            @part_membership.shipment = Shipment.find_by_id(shipment_id)
            if @part_membership.shipment.present? && @part_membership.shipment.from_type == Supplier.name
                @part_membership.part.supplier = @part_membership.shipment.from
            end
        end

        if !part_id.blank? && @part_membership.part_type == PartMembership::INVENTORY
            @part_membership.part = Part.find_by_id(part_id)
            not_found unless @part_membership.part.present?
            not_found unless @part_membership.part.company == current_user.company
            @part_membership.name = @part_membership.part.master_part.name
            @part_membership.material_number = @part_membership.part.material_number
            @part_membership.serial_number = @part_membership.part.serial_number

            # For Inventory parts
            if @part_membership.job.present?
                @part_membership.part.asset_on_job @part_membership.job
            elsif @part_membership.shipment.present?
                @part_membership.part.asset_shipping @part_membership.shipment
            end
        end

        # For Rental parts
        if @part_membership.part.present? && @part_membership.part_type == PartMembership::RENTAL
            if @part_membership.job.present?
                @part_membership.part.asset_on_job @part_membership.job
            elsif @part_membership.shipment.present?
                @part_membership.part.asset_shipping @part_membership.shipment
            end
        end

        if @part_membership.save
            if @part_membership.job.present?
                if @part_membership.part.present?
                    AssetActivity.delay.add(current_user, AssetActivity::ADDED_TO_JOB, @part_membership.part, @part_membership.job)
                    Activity.delay.add(current_user, Activity::ASSET_ADDED, @part_membership.part, @part_membership.part.serial_number, @part_membership.job)
                else
                    Activity.delay.add(current_user, Activity::ASSET_ADDED, nil, @part_membership.serial_number, @part_membership.job)
                end
            elsif @part_membership.shipment.present?
                AssetActivity.delay.add(current_user, AssetActivity::ADDED_TO_SHIPMENT, @part_membership.part, @part_membership.shipment)
            end
        end
    end

    def edit
        @part_membership = PartMembership.find_by_id(params[:id])
    end

    def update
        @part_membership = PartMembership.find_by_id(params[:id])

        if params[:usage].present?
            @part_membership.update_attribute(:usage, Float(params[:usage]))
        elsif params[:part_membership].present?
            @part_membership.update_attributes(params[:part_membership])
        end
    end

    def destroy
        @part_membership = PartMembership.find_by_id(params[:id])
        not_found unless @part_membership.present?

        PartMembership.transaction do
            if @part_membership.destroy
                if @part_membership.job.present?
                    if @part_membership.part.present?
                        @part_membership.part.removed true
                        AssetActivity.delay.add(current_user, AssetActivity::DELETED_FROM_JOB, @part_membership.part, @part_membership.job)
                        Activity.delay.add(current_user, Activity::ASSET_REMOVED, @part_membership.part, @part_membership.part.serial_number, @part_membership.job)
                    else
                        Activity.delay.add(current_user, Activity::ASSET_REMOVED, nil, @part_membership.serial_number, @part_membership.job)
                    end
                elsif @part_membership.shipment.present? && @part_membership.part.present?
                    if @part_membership.part.rental
                        @part_membership.part.destroy
                    else
                        AssetActivity.delay.add(current_user, AssetActivity::DELETED_FROM_SHIPMENT, @part_membership.part, @part_membership.shipment)
                        @part_membership.part.removed false
                    end
                end
            end
        end
    end

end
