class DistrictsController < ApplicationController
    before_filter :signed_in_user, only: [:index]
    before_filter :signed_in_admin, only: [:index]
    set_tab :districts

    def index
        @districts = District.from_company(current_user.company).paginate(page: params[:page])
    end

    def show
        @district = District.find(params[:id])
        not_found unless @district.company == current_user.company
    end

    def new
        @district = District.new
        @company = current_user.company
    end

    def create
        @district = District.new(params[:district])
        @district.company = current_user.company

        saved = @district.save

        respond_to do |format|
            format.html {
                if saved

                    Activity.add(self.current_user, Activity::DISTRICT_CREATED, @district, @district.name)

                    flash[:success] = "District created - #{@district.name}"
                    redirect_to districts_path
                else
                    render 'new'
                end
            }
            format.js
        end
    end

    def edit
        @district = District.find(params[:id])
        not_found unless @district.company == current_user.company
        @company = current_user.company
    end

    def update

        @district = District.find(params[:id])
        not_found unless @district.company == current_user.company

        if @district.update_attributes(params[:district])

            Activity.add(self.current_user, Activity::DISTRICT_UPDATED, @district, @district.name)

            flash[:success] = "District updated"
            redirect_to districts_path
        else
            @company = current_user.company
            render 'edit'
        end
    end

    def destroy
        @district = District.find(params[:id])
        not_found unless @district.company == current_user.company
        @district.destroy

        Activity.add(self.current_user, Activity::DISTRICT_DESTROYED, @district, @district.name)

        flash[:success] = "District destroyed."
        redirect_to districts_path
    end


end
