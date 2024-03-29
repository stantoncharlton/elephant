class WellsController < ApplicationController
    before_filter :signed_in_user, only: [:index, :show]
    before_filter :signed_in_user, only: [:new, :create, :edit, :update]

    def index
        @wells = []

        respond_to do |format|
            format.html {
                if params[:field_id].present?
                    field = Field.find_by_id(params[:field_id])
                    if field.company == current_user.company
                        @wells = field.wells
                    end
                end
            }
            format.js {
                @query = params[:search]
                @wells = Well.search_with_field(params, current_user.company, Field.find_by_id(params[:field_id])).results
            }
        end

    end

    def show

        @well = Well.find_by_id(params[:id])
        not_found unless @well.present? && @well.company == current_user.company

        @divisions = []
        @divisions << ["All Divisions", 0]
        current_user.company.divisions.each do |division|
            @divisions << [division.name, division.id]
        end

        @jobs = UserRole.limit_jobs_scope current_user, @well.jobs


    end

    def new
        @well = Well.new
        @field = Field.find_by_id(params[:field_id])
    end

    def create
        field_id = params[:well][:field_id]
        params[:well].delete(:field_id)

        rig_id = params[:well][:rig_id]
        params[:well].delete(:rig_id)

        @well = Well.new(params[:well])
        @well.company = current_user.company
        @well.field = Field.find_by_id(field_id)
        @well.rig = Rig.find_by_id(rig_id)
        @well.save
    end

    def edit
        store_last_location

        @well = Well.find_by_id(params[:id])
        @field = @well.field
        not_found unless @well.company == current_user.company

        @df = DynamicField.new
        @df.value_type = 10
    end

    def update

        @well = Well.find_by_id(params[:id])
        not_found unless @well.present? && @well.company == current_user.company

        if params[:update_field].present? && params[:update_field] == "true" &&
                params[:field].present? && params[:value].present?
            case params[:field]
                when "location"
                    @well.update_attribute(:location, params[:value])
                when "bottom_hole_location"
                    @well.update_attribute(:bottom_hole_location, params[:value])
                when "datum"
                    @well.update_attribute(:datum, params[:value])
                when "rig_id"
                    @rig = Rig.find_by_id(params[:value])
                    @well.rig = @rig
                    @well.save
                when "name"
                    if !params[:value].blank?
                        @well.update_attribute(:name, params[:value])
                    end
            end
        else
            field_id = params[:well][:field_id]
            params[:well].delete(:field_id)

            rig_id = params[:well][:rig_id]
            params[:well].delete(:rig_id)

            Well.transaction do
                if @well.update_attributes(params[:well])
                    @well.rig = Rig.find_by_id(rig_id)
                    @well.save
                    flash[:success] = "Well updated"
                    redirect_back_or root_path
                else
                    render 'edit'
                end
            end
        end

    end

end
