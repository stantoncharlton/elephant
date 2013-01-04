class WellsController < ApplicationController
    before_filter :signed_in_user, only: [:index, :show]
    before_filter :signed_in_user, only: [:new, :create, :edit, :update]

    def index
        @wells = []

        if params[:field_id].present?
            field = Field.find_by_id(params[:field_id])
            if field.company == current_user.company
                @wells = field.wells
            end
        end
    end

    def show

    end

    def new
        @well = Well.new
        @field = Field.find_by_id(params[:field_id])
    end

    def create
        field_id = params[:well][:field_id]
        params[:well].delete(:field_id)

        @well = Well.new(params[:well])
        @well.company = current_user.company
        @well.field = Field.find_by_id(field_id)
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
        not_found unless @well.company == current_user.company

        respond_to do |format|
            format.html do
                field_id = params[:well][:field_id]
                params[:well].delete(:field_id)

                Well.transaction do
                    if @well.update_attributes(params[:well])
                        flash[:success] = "Well updated"
                        redirect_back_or root_path
                    else
                        render 'edit'
                    end
                end
            end

            format.js do
                params.each do |key, value|
                    if key.include? "value_type"
                        @well.update_attribute(key, value)
                    end
                end

                render :nothing => true, :status => :ok
            end
        end

    end

end
