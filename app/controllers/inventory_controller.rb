class InventoryController < ApplicationController
    before_filter :signed_in_user_inventory, only: [:index, :show]
    set_tab :inventory

    include InventoryHelper


    def index
        if params[:district].present?
            @district_present = true
            @district = District.find_by_id(params[:district])
            not_found unless @district.company == current_user.company
        elsif current_user.district.present?
            @district = current_user.district
        elsif current_user.company.districts.where(:master => true).count == 1
            @district = current_user.company.districts.where(:master => true).first.districts.first
        else
            @district = nil
        end

        not_found unless @district.present?
        redirect_to inventory_path(@district)
    end


    def show
        @district = District.find_by_id(params[:id])
        not_found unless @district.present? && @district.company == current_user.company

        @condensed = true

        if current_user.role.district_read?
            @parts = Part.includes(:parts, :master_part).where("parts.rental IS FALSE").where("parts.district_id = :district_id", district_id: @district.id).where(:template => false).order("parts.material_number ASC")
        elsif current_user.role.limit_to_assigned_jobs?
            @parts = Part.includes(:parts, :master_part).where("parts.rental IS FALSE").where("parts.district_id = :district_id", district_id: @district.id).where(:template => false).order("parts.material_number ASC")
        else
            @parts = Part.where("parts.rental IS FALSE").where("parts.district_id = :district_id", district_id: @district.id).where(:template => false).order("parts.material_number ASC")
        end

        @parts = @parts.includes(:parts, :master_part).includes(:warehouse).includes(current_job: {well: :rig}).includes(current_job: :field)

        respond_to do |format|
            format.html {

            }
            format.js {

            }
            format.xlsx {
                excel = parts_to_excel @parts
                send_data excel.to_stream.read, :filename => "Inventory List.xlsx", :type => "application/vnd.openxmlformates-officedocument.spreadsheetml.sheet"
            }
        end

    end

end
