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
            @shipment.from_name = '(Not Set)'
            @shipment.from_editable = true
        end
        @shipment.to_name = '(Not Set)'
        @shipment.company = current_user.company
        @shipment.user = current_user
        ## Remove
        @shipment.status = Shipment::CREATING
        @shipment.save

        if request.format == "html"
            redirect_to @shipment
        end
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

            @shipment.shipper = Shipper.find_by_id(params[:shipper_id])

            if params[:update_field].present? && params[:update_field] == "true" &&
                    params[:field].present? && params[:value].present?
                case params[:field]
                    when "receive_shipment"
                        @shipment = Shipment.find_by_id(params[:value])
                        @shipment.receive_shipment current_user

                        begin
                            path = URI(request.referer).path
                            if path.starts_with?("/parts/")
                                @part = Part.find_by_id(path.gsub("/parts/", ''))
                            end
                        rescue
                        end
                end
            else
                part_memberships = @shipment.part_memberships

                if !@shipment.from_editable
                    part_memberships.each do |pm|
                        if pm.job_part_membership.present?
                            pm.job_part_membership.update_attribute(:shipping, false)
                        end
                        pm.destroy
                        if pm.part.present?
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
                                if part_membership.part.present?
                                    part_membership.part.asset_shipping @shipment
                                    AssetActivity.delay.add(current_user, AssetActivity::ADDED_TO_SHIPMENT, part_membership.part, @shipment)
                                end
                                if @shipment.from_type == Supplier.name
                                    part_membership.supplier = @shipment.from
                                end
                            end
                        end
                    end
                end

                @shipment = Shipment.find_by_id(@shipment.id)
                part_memberships = @shipment.part_memberships

                if params[:shipment].present?
                    from_type = params[:shipment][:from_type]
                    to_type = params[:shipment][:to_type]

                    inbound_part_memberships = []
                    if from_type == Job.name || @shipment.from.present?
                        job = params[:from_id_job].present? ? Job.find_by_id(params[:from_id_job]) : @shipment.from
                        inbound_part_memberships = job.inbound_shipments_part_memberships.to_a
                    end

                    part_memberships.each do |pm|
                        if @shipment.from.present?
                            pm.from = @shipment.from
                            pm.from_name = @shipment.from_name
                        end
                        case from_type
                            when Warehouse.name
                                pm.from = Warehouse.find_by_id(params[:from_id_warehouse])
                                pm.from_name = pm.from.present? ? pm.from.name : ""
                            when Supplier.name
                                pm.from = Supplier.find_by_id(params[:from_id_supplier])
                                pm.from_name = pm.from.present? ? pm.from.name : ""
                            when Job.name
                                pm.from = Job.find_by_id(params[:from_id_job])
                                pm.from_name = pm.from.present? ? (pm.from.well.rig.present? ? pm.from.well.rig.name + " - " : "") + pm.from.field.name + " | " + pm.from.well.name : ""
                        end

                        case to_type
                            when Warehouse.name
                                pm.to = Warehouse.find_by_id(params[:to_id_warehouse])
                                pm.to_name = pm.to.present? ? pm.to.name : ""
                            when Supplier.name
                                pm.to = Supplier.find_by_id(params[:to_id_supplier])
                                pm.to_name = pm.to.present? ? pm.to.name : ""
                            when Job.name
                                pm.to = Job.find_by_id(params[:to_id_job])
                                pm.to_name = pm.to.present? ? (pm.to.well.rig.present? ? pm.to.well.rig.name + " - " : "") + pm.to.field.name + " | " + pm.to.well.name : ""
                            when "Home"
                                if pm.part.present? && (pm.part.supplier.present? || pm.part.warehouse.present?)
                                    if pm.part.supplier.present?
                                        pm.to = pm.part.supplier
                                        pm.to_name = pm.part.supplier.name
                                    else
                                        pm.to = pm.part.warehouse
                                        pm.to_name = pm.part.warehouse.name
                                    end
                                else
                                    found = inbound_part_memberships.find { |p| p.serial_number == pm.serial_number }
                                    if found.present?
                                        pm.to = found.from
                                        pm.to_name = found.from_name
                                    elsif pm.part.present?
                                        if pm.part.rental
                                            pm.to = @shipment.district.suppliers.first
                                            pm.to_name = pm.to.name
                                        else
                                            pm.to = @shipment.district.warehouses.first
                                            pm.to_name = pm.to.name
                                        end
                                    else
                                        pm.to = @shipment.district.suppliers.first
                                        pm.to_name = pm.to.name
                                    end
                                end
                        end
                        pm.save
                    end

                    @shipment.status = Shipment::IN_TRANSIT
                end

                from_name = part_memberships.map { |pm| pm.from_name }.select { |name| !name.blank? }.uniq.join(", ")
                if from_name.blank?
                    from_name = '(Not Set)'
                end
                to_name = part_memberships.map { |pm| pm.to_name }.select { |name| !name.blank? }.uniq.join(", ")
                if to_name.blank?
                    to_name = '(Not Set)'
                end
                @shipment.from_name = from_name
                @shipment.to_name = to_name
                if part_memberships.any?
                    @shipment.to = part_memberships.first.to
                end

                if params[:commit] == 'send'
                    flash[:success] = "Shipment sent"
                    @shipment.status = Shipment::IN_TRANSIT
                elsif params[:commit] == 'receive'
                    flash[:success] = "Shipment received"
                    @shipment.status = Shipment::COMPLETE
                end
                @shipment.save

                @shipment = Shipment.find_by_id(@shipment.id)
                if params[:commit] == 'receive'
                    @shipment.receive_shipment(current_user)
                end

                if request.format == "html"
                    redirect_to inventory_path(@shipment.district, anchor: "shipping")
                end
            end
        end
    end

    def destroy
        @shipment = Shipment.find(params[:id])
        @part_memberships = @shipment.part_memberships.to_a
        if @shipment.destroy

            @part_memberships.each do |pm|
                if pm.job_part_membership.present?
                    pm.job_part_membership.update_attribute(:shipping, false)
                end
                if pm.part.present?
                    pm.part.removed false
                    AssetActivity.delay.add(current_user, AssetActivity::DELETED_FROM_SHIPMENT, pm.part, @shipment)
                end
            end
        end

        if request.format == "html"
            redirect_to inventory_path(@shipment.district, anchor: "shipping")
        end
    end


end
