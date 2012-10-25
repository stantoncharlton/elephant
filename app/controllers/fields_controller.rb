class FieldsController < ApplicationController
    before_filter :signed_in_user, only: [:index, :show]
    before_filter :signed_in_user, only: [:new, :create]

    def index
        @fields = []

        if params[:district_id].present?
            district = District.find_by_id(params[:district_id])
            if district.company == current_user.company
                @fields = district.fields
            end
        end
    end

    def show

    end

    def new
        @field = Field.new
        @district  = District.find_by_id(params[:district_id])
    end

    def create
        district_id = params[:field][:district_id]
        params[:field].delete(:district_id)

        @field = Field.new(params[:field])
        @field.company = current_user.company
        @field.district = District.find_by_id(district_id)
        @field.save
    end




end
