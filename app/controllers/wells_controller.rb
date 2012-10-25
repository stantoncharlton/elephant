class WellsController < ApplicationController
    before_filter :signed_in_user, only: [:index, :show]
    before_filter :signed_in_user, only: [:new, :create]

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
        @field  = Field.find_by_id(params[:field_id])
    end

    def create
        field_id = params[:well][:field_id]
        params[:well].delete(:field_id)

        @well = Well.new(params[:well])
        @well.company = current_user.company
        @well.field = Field.find_by_id(field_id)
        @well.save
    end

end
