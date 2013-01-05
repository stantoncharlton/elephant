class SegmentsController < ApplicationController
    before_filter :signed_in_user, only: [:index, :show]
    before_filter :signed_in_admin, only: [:new, :create, :edit, :update, :destroy]

    respond_to :js

    def index
        if params[:segment_id].present?
            @segment = Segment.find_by_id(params[:segment_id])
            not_found unless @segment.company == current_user.company
        else
            @segments = Segment.from_company(current_user.company).order("name ASC")
        end

    end

    def show

        @segment = Segment.find_by_id(params[:id])
        not_found unless @segment.company == current_user.company

        @jobs = Segment.from_company_for_user(@segment, params, current_user, current_user.company).results
    end

    def new
        @segment = Segment.new
        division = Division.find_by_id(params[:division])
        not_found unless division.company == current_user.company
        @segment.division = division
    end

    def create
        division = Division.find_by_id(params[:segment][:division_id])
        not_found unless division.company == current_user.company
        params[:segment].delete(:division_id)

        @segment = Segment.new(params[:segment])
        @segment.division = division
        @segment.company = current_user.company

        if @segment.save

            #Activity.add(self.current_user, Activity::PRODUCT_LINE_CREATED, @product_line, @product_line.name)

            flash[:success] = "Segment created - #{@segment.name}"
            #redirect_to job_template_path_path
        else
            render 'error'
        end
    end

    def edit
        @segment = Segment.find(params[:id])
        not_found unless @segment.company == current_user.company
    end

    def update

        @segment = Segment.find(params[:id])
        not_found unless @segment.company == current_user.company

        if @segment.update_attributes(params[:segment])

            #Activity.add(self.current_user, Activity::PRODUCT_LINE_UPDATED, @product_line, @product_line.name)

            flash[:success] = "Segment updated"
            #redirect_to job_templates_path
        else
            render 'edit'
        end
    end

    def destroy
        @segment = Segment.find(params[:id])
        not_found unless @segment.company == current_user.company
        @segment.destroy

        #Activity.add(self.current_user, Activity::PRODUCT_LINE_DESTROYED, @product_line, @product_line.name)

        flash[:success] = "Segment deleted"
    end
end
