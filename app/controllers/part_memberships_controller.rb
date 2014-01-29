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
            when 'accessory'
                @part_membership.part_type = PartMembership::ACCESSORY
                @part_membership.name = params["accessory_name"]
                @part_membership.serial_number = params["accessory_serial_number"]
        end

        @part_membership.inner_diameter = BigDecimal(params[:id])
        @part_membership.outer_diameter = BigDecimal(params[:od])
        @part_membership.length = BigDecimal(params[:length])

        if !job_id.blank?
            @part_membership.job = Job.find_by_id(job_id)
            not_found unless @part_membership.job.present? && @part_membership.job.company == current_user.company
        else
            @part_membership.shipment = Shipment.find_by_id(shipment_id)
            if @part_membership.shipment.present? && @part_membership.shipment.from_type == Supplier.name
                @part_membership.supplier = @part_membership.shipment.from
            end
        end

        if !part_id.blank? && @part_membership.part_type == PartMembership::INVENTORY
            @part_membership.part = Part.find_by_id(part_id)
            not_found unless @part_membership.part.present?
            not_found unless @part_membership.part.company == current_user.company
            @part_membership.name = @part_membership.part.master_part.name
            @part_membership.material_number = @part_membership.part.material_number
            @part_membership.serial_number = @part_membership.part.serial_number

            if @part_membership.job.present?
                @part_membership.part.asset_on_job @part_membership.job
            elsif @part_membership.shipment.present?
                @part_membership.part.asset_shipping @part_membership.shipment
            end
        end

        if @part_membership.save
            if @part_membership.job.present?
                if @part_membership.part.present?
                    Activity.delay.add(current_user, Activity::ASSET_ADDED, @part_membership.part, @part_membership.part.serial_number, @part_membership.job)
                else
                    Activity.delay.add(current_user, Activity::ASSET_ADDED, nil, @part_membership.serial_number, @part_membership.job)
                end
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
                        Activity.delay.add(current_user, Activity::ASSET_REMOVED, @part_membership.part, @part_membership.part.serial_number, @part_membership.job)
                    else
                        Activity.delay.add(current_user, Activity::ASSET_REMOVED, nil, @part_membership.serial_number, @part_membership.job)
                    end
                elsif @part_membership.shipment.present? && @part_membership.part.present?
                    @part_membership.part.removed false
                end
            end
        end
    end

end
