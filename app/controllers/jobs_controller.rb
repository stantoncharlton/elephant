class JobsController < ApplicationController
    before_filter :signed_in_user, only: [:index, :show]
    before_filter :signed_in_user, only: [:new, :create]
    set_tab :jobs

    def index

        @jobs = Job.paginate(page: params[:page], limit: 10)

    end

    def show

    end

    def new
        @job = Job.new

        @districts = current_user.company.districts
        @fields = current_user.company.fields
        @wells = Array.new
    end

end
