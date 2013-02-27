class SecondaryToolsController < ApplicationController
    before_filter :signed_in_user, only: [:index, :new, :create, :destroy]

    set_tab :tools

    def index

        if params[:division]
            @division = Division.find_by_id(params[:division])
            not_found unless @division.company == current_user.company
        end

        render 'tools/secondary/index'
    end

    def new

    end

    def create

    end

    def destroy

    end
end
