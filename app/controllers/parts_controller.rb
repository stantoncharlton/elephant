class PartsController < ApplicationController
    before_filter :signed_in_user, only: [:index]
    before_filter :signed_in_user_inventory, only: [:show, :new, :create, :update, :destroy]
    set_tab :inventory

    include InventoryHelper


    def index

        respond_to do |format|
            format.html { not_found }
            format.js {
                @query = params[:search]
                @parts = Part.search_no_district(params, current_user.company).results
            }
            format.json {
                if params[:q].present?
                    params[:search] = params[:q]
                end

                if params[:material_number].present?
                    district = District.find_by_id(params[:district_id])
                    @parts = Part.search_parts(params, current_user.company, params[:material_number], district, current_user).results
                else
                    if current_user.role.global_read? && current_user.district.nil?
                        @parts = Part.search_no_district(params, current_user.company).results
                    else
                        district = District.find_by_id(params[:district_id])
                        @parts = Part.search(params, current_user.company, district, current_user).results
                    end
                end

                if params[:show_master].present? && params[:show_master] == "false"
                    @parts = @parts.select { |p| p.template == false }
                end

                if @parts.empty?
                    @parts << Part.new
                    render json: @parts.map { |part| {:value => "No asset found or available...", :name => "", :id => -1, :district_serial_number => -1, :warehouse => ""} }
                    return
                end

                if params[:q].present?
                    render json: @parts.map { |part| {:name => part.master_part.present? ? part.master_part.name : part.name, :id => part.id, :district_serial_number => part.district_serial_number, :serial_number => part.serial_number, material_number: part.material_number, warehouse: part.warehouse.present? ? part.warehouse.name : '-'} }
                else
                    render json: @parts.map { |part| {:label => part.master_part.present? ? part.master_part.name : part.name, :id => part.id, :district_serial_number => part.district_serial_number, :serial_number => part.serial_number, material_number: part.material_number, warehouse: part.warehouse.present? ? part.warehouse.name : '-'} }
                end
            }
        end

    end


    def show
        if params[:material_number].present?
            @part = Part.where("parts.company_id = :company_id AND parts.template IS TRUE AND parts.material_number = :material_number", company_id: current_user.company_id, material_number: params[:material_number]).limit(1).first
        else
            @part = Part.find(params[:id])
            not_found unless @part.present? && @part.company == current_user.company

            if params[:show_decommissioned] == "true"
                @showing_decommissioned = true
                @parts = @part.parts.paginate(page: params[:page], limit: 100)
            else
                @showing_decommissioned = false
                @parts = @part.parts.where("parts.status != ?", Part::DECOMMISSIONED).paginate(page: params[:page], limit: 100)
            end

            respond_to do |format|
                format.html {

                }
                format.js {

                }
                format.xlsx {
                    excel = parts_to_excel @part.parts
                    send_data excel.to_stream.read, :filename => "Asset (#{@part.name}) List.xlsx", :type => "application/vnd.openxmlformates-officedocument.spreadsheetml.sheet"
                }
            end
        end
    end


    def new
        @part = Part.new
        @part.template = params[:template] == 'true'

        if params[:master_part].present?
            @part.master_part = Part.find_by_id(params[:master_part])
            @part.district = @part.master_part.district
        else
            @district = District.find_by_id(params[:district])
        end
    end

    def create
        district_id = params[:part][:district_id]
        params[:part].delete(:district_id)

        master_part_id = params[:part][:master_part_id]
        params[:part].delete(:master_part_id)

        @part = Part.new(params[:part])
        @part.company = current_user.company

        if !master_part_id.blank?
            @part.master_part = Part.find_by_id(master_part_id)
            @part.material_number = @part.master_part.material_number
            @part.district = @part.master_part.district
            @part.warehouse = @part.master_part.warehouse
            @part.template = false
            @part.status = Part::AVAILABLE
        else
            @part.district = District.find_by_id(district_id)
            @part.template = true
        end

        respond_to do |format|
            format.html {
                if @part.save
                    flash[:success] = "Asset created - #{@part.name}"
                    redirect_to @part
                else
                    @district = District.find_by_id(district_id)
                    render 'new'
                end
            }
            format.js {
                @part.save
            }
        end
    end

    def update
        @part = Part.find(params[:id])

        @part_update = false
        @inline_part_update = false

        if params[:update_field].present? && params[:update_field] == "true"
            if params[:field].present? && params[:value].present?
                case params[:field]
                    when "warehouse_id"
                        @part.update_attribute(:warehouse_id, Warehouse.find_by_id(params[:value]).id)
                        render :nothing => true, :status => 200
                    when "receive_asset"
                        @warehouse = Warehouse.find_by_id(params[:value])
                        @part.warehouse = @warehouse
                        @part.status = Part::AVAILABLE
                        @part.save
                end
            end
        elsif params[:transfer] == "true"
            @part.status = Part::AVAILABLE
            @part_redress = PartRedress.transfer(@part.company, @part.current_job, @part, current_user)
            @part.current_job = nil
            @part.save
            if !params[:part_page].present?
                @part_update = true
            end

            if params[:job].present? && params[:part_membership].present?
                part_membership = PartMembership.find_by_id(params[:part_membership])
                primary_tool = part_membership.primary_tool
                job = Job.find_by_id(params[:job])

                new_primary_tool = primary_tool.duplicate job, current_user

                new_part_membership = PartMembership.new(template: false)
                new_part_membership.material_number = part_membership.material_number
                new_part_membership.optional = true
                new_part_membership.job = job
                new_part_membership.primary_tool = new_primary_tool
                new_part_membership.part = @part
                new_part_membership.company = current_user.company
                new_part_membership.track_usage = part_membership.template_part_membership.track_usage
                new_part_membership.save
                new_part_membership.part.status = Part::ON_JOB
                new_part_membership.part.current_job = job
                new_part_membership.part.save

                Activity.delay.add(current_user, Activity::ASSET_ADDED, new_part_membership.part, new_part_membership.part.serial_number, new_part_membership.job)
            end

        elsif params[:transfer_warehouse] == "true"
            @warehouse = Warehouse.find_by_id(params[:warehouse])
            @part.warehouse = @warehouse

            @master_part = @warehouse.parts.where(:template => true).where("parts.material_number = ?", @part.material_number).limit(1).first
            if @master_part.nil?
                @master_part = Part.new(template: true)
                @master_part.warehouse = @warehouse
                @master_part.material_number = @part.master_part.material_number
                @master_part.name = @part.master_part.name
                @master_part.company == current_user.company
                @master_part.save
            end

            @part.master_part = @master_part

            @part.save

            @part_update = true

            if request.format == "html"
                redirect_to @part
            else
                @part_redress = PartRedress.where(:part_id => @part.id).order("created_at ASC").last
            end
        elsif params[:cleaned] == "true"
            @part.status = Part::AVAILABLE
            @part_redress = PartRedress.finish_redress(@part.company, @part, current_user)
            @part.save
            @part_redressed = true
        elsif params[:add_notes] == "true"
            @part_redress = PartRedress.where(:part_id => @part.id).order("created_at ASC").last
            if !params[:notes].blank?
                note = JobNote.new(text: params[:notes], note_type: JobNote::NOTE)
                note.company = current_user.company
                note.user = current_user
                note.user_name = current_user.name
                note.owner = @part_redress
                note.save

                @part_redressed = true
            end
        elsif params[:decommission] == "true"
            @part.status = Part::DECOMMISSIONED
            @part.save

            flash[:success] = "Asset Decommissioned"
            redirect_to @part
        elsif params[:recommission] == "true"
            @part.status = Part::AVAILABLE
            @part.save

            flash[:success] = "Asset Recommissioned"
            redirect_to @part
        elsif params[:part][:name].present?
            @part_update = true
            @part.update_attribute(:name, params[:part][:name])
        elsif params[:part][:material_number].present?
            @part_update = true
            @material_number_update = true
            Part.transaction do
                @part.parts.each do |p|
                    p.update_attribute(:material_number, params[:part][:material_number])
                end
                @part.update_attribute(:material_number, params[:part][:material_number])
            end
        elsif params[:part][:serial_number].present?
            @part_update = true
            @serial_number_update = true
            Part.transaction do
                @part.parts.each do |p|
                    p.update_attribute(:serial_number, params[:part][:serial_number])
                end
                @part.update_attribute(:serial_number, params[:part][:serial_number])
            end
        end
    end

    def destroy
        @part = Part.find(params[:id])
        not_found unless @part.company == current_user.company

        if @part.destroy
            if @part.master_part.present?
                redirect_to @part.master_part
            else
                redirect_to inventory_index_path
            end
        end
    end

end
