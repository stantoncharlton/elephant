class IssuesController < ApplicationController
    before_filter :signed_in_user, only: [:show]

   def show
        @issue = Issue.find_by_id(params[:id])
   end

end
