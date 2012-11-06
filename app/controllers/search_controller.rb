class SearchController < ApplicationController
    before_filter :signed_in_user, only: [:index]


    require 'will_paginate/array'

    def index

        #search(params[:search])
        #        @jobs = Job.from_user(current_user)

        @term = params[:search]

        @search = search(params)


        #@jobs = Job.from_company(current_user.company).search(params[:search]).paginate(page: params[:page], limit: 10)


    end

protected
    def search(options)
        Sunspot.search(Job) do
            keywords options[:search]
            order_by :created_at, :desc
            paginate :page => options[:page]
        end
    end
end
