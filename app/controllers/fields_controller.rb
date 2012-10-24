class FieldsController < ApplicationController
    before_filter :signed_in_user, only: [:index, :show]
    before_filter :signed_in_user, only: [:new, :create]

    def index

    end

    def show

    end

    def new
        @field = Field.new

        puts params[:district_id].to_s + "......................."

        @district  = District.find_by_id(params[:district_id])
    end

    def create
        @field = Field.new(params[:field])
        @field.company = current_user.company
        @field.district = District.find(district_id)
        @field.save
    end

end
