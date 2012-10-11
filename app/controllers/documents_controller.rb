class DocumentsController < ApplicationController
    before_filter :signed_in_admin, only: [:new, :create]

    def new
        @document = Document.new
    end

    def create
        @document = Document.create(params[:document])
    end


end
