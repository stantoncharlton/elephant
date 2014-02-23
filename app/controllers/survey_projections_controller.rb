class SurveyProjectionsController < ApplicationController
    before_filter :signed_in_user, only: [:new]

    def new
        @survey = Survey.find_by_id(params[:survey])
        not_found unless @survey.present?
    end

end
