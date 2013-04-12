class DocumentSharesController < ApplicationController
    before_filter :signed_in_user, only: [:index, :show, :new, :create, :destroy]

    def index

    end
end
