class ToolsController < ApplicationController
    before_filter :signed_in_admin, only: [:create, :update, :destroy]


    def create

    end

    def update

    end

    def destroy

    end

end
