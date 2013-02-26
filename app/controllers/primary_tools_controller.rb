class PrimaryToolsController < ApplicationController
    before_filter :signed_in_admin, only: [:create, :destroy]


    def create

    end

    def destroy

    end
end
