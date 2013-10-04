class PartsController < ApplicationController
    before_filter :signed_in_user_inventory, only: [:index, :show, :new, :create, :update, :destroy]
    set_tab :inventory


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
                    @parts = Part.search_parts(params, current_user.company, params[:material_number], params[:district_id]).results
                else
                    if current_user.role.global_read? && current_user.district.nil?
                        @parts = Part.search_no_district(params, current_user.company).results
                    elsif current_user.role.district_read?
                        @parts = Part.search_master_district(params, current_user.company, params[:district_id]).results
                    else
                        @parts = Part.search(params, current_user.company, params[:district_id]).results
                    end
                end

                if @parts.empty?
                    @parts << Part.new
                    render json: @parts.map { |part| {:value => "No asset found or available...", :name => "", :id => -1, :district_serial_number => -1} }
                    return
                end

                if params[:q].present?
                    render json: @parts.map { |part| {:name => part.master_part.present? ? part.master_part.name : part.name, :id => part.id, :district_serial_number => part.district_serial_number, :serial_number => part.serial_number, material_number: part.material_number} }
                else
                    render json: @parts.map { |part| {:label => part.master_part.present? ? part.master_part.name : part.name, :id => part.id, :district_serial_number => part.district_serial_number, :serial_number => part.serial_number, material_number: part.material_number} }
                end
            }
        end

    end


    def show
        if params[:material_number].present?
            @part = Part.where("parts.company_id = :company_id AND parts.template IS TRUE AND parts.material_number = :material_number", company_id: current_user.company_id, material_number: params[:material_number]).limit(1).first
        else
            @part = Part.find(params[:id])
            not_found unless @part.company == current_user.company

            if params[:show_decommissioned] == "true"
                @showing_decommissioned = true
                @parts = @part.parts.paginate(page: params[:page], limit: 20)
            else
                @showing_decommissioned = false
                @parts = @part.parts.where("parts.status != ?", Part::DECOMMISSIONED).paginate(page: params[:page], limit: 20)
            end
        end
    end


    def new
        @part = Part.new
        @part.template = params[:template] == 'true'

        if params[:master_part].present?
            @part.master_part = Part.find_by_id(params[:master_part])
            not_found unless @part.master_part.company == current_user.company
            @part.district = @part.master_part.district
        else
            @district = District.find_by_id(params[:district])
            not_found unless @district.company == current_user.company
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
            not_found unless @part.master_part.company == current_user.company
            @part.material_number = @part.master_part.material_number
            @part.district = @part.master_part.district
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
                    not_found unless @district.company == current_user.company
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
        not_found unless @part.company == current_user.company

        @part_update = false

        if params[:receive] == "true"
            @part.status = Part::IN_REDRESS

            PartRedress.receive(@part.company, @part.current_job, @part, current_user)

            @part.save
        elsif params[:transfer] == "true"
            @part.status = Part::AVAILABLE
            @part.current_job = nil

            PartRedress.transfer(@part.company, @part.current_job, @part, current_user)

            @part.save
        elsif params[:cleaned] == "true"
            @part.status = Part::AVAILABLE

            @part_redress = PartRedress.finish_redress(@part.company, @part.current_job, @part, current_user, params[:notes])

            @part.current_job = nil
            @part.save
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
        end
    end

    def destroy
        @part = Part.find(params[:id])
        not_found unless @part.company == current_user.company

        if @part.destroy
            if @part.master_part.present?
                redirect_back_or @part.master_part
            else
                redirect_to inventory_path
            end
        end
    end

end
