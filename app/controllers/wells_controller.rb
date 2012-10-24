class WellsController < ApplicationController
    before_filter :signed_in_user, only: [:index, :show]
    before_filter :signed_in_user, only: [:new, :create]

    def index

    end

    def show

    end

    def new
        @well = Well.new
    end

    def create

    end

end
