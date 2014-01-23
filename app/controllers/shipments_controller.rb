class ShipmentsController < ApplicationController
    before_filter :signed_in_user, only: [:index, :new, :show, :create, :destroy]

    def index

    end


    def show
        @shipment = Shipment.find(params[:id])
        not_found unless @shipment.present?
    end

    def new
        @shipment = Shipment.new
    end

    def create
        @shipment = Shipment.new()
        if params[:district]
            @shipment.district = District.find(params[:district])
        end
        @shipment.company = current_user.company
        @shipment.user = current_user
        @shipment.status = 0
        @shipment.save
    end

    def destroy
        @shipment = Shipment.find(params[:id])
        @shipment.destroy
    end


end
