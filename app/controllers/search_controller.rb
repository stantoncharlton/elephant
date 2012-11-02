class SearchController < ApplicationController

    def index

        @term = params[:search]
        #search(params[:search])
        @jobs = Job.all.paginate(page: params[:page], limit: 10)

    end

end
