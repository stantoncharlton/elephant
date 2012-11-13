class DistrictsController < ApplicationController
    before_filter :signed_in_user, only: [:index]
    before_filter :signed_in_admin, only: [:index]
    set_tab :districts

    def index
        @districts = District.from_company(current_user.company).paginate(page: params[:page])
    end

    def show
        @district = District.find_by_id(params[:id])
        not_found unless @district.company == current_user.company

        @jobs = Job.from_district(@district)
    end

    def new
        @district = District.new
        @company = current_user.company

        @countries = Country.all
        @states = State.all
    end

    def create
        country_id = params[:district][:country_id]
        params[:district].delete(:country_id)

        state_id = params[:district][:state_id]
        params[:district].delete(:state_id)

        @district = District.new(params[:district])
        @district.company = current_user.company
        @district.country = Country.find_by_id(country_id)
        if state_id.present?
            @district.state = State.find_by_id(state_id)
        end

        saved = @district.save

        respond_to do |format|
            format.html {
                if saved

                    Activity.add(self.current_user, Activity::DISTRICT_CREATED, @district, @district.name)

                    flash[:success] = "District created - #{@district.name}"
                    redirect_to districts_path
                else
                    @countries = Country.all
                    @states = State.all
                    render 'new'
                end
            }
            format.js
        end
    end

    def edit
        @district = District.find_by_id(params[:id])
        not_found unless @district.company == current_user.company
        @company = current_user.company

        @countries = Country.all
        @states = State.all
    end

    def update

        @district = District.find_by_id(params[:id])
        not_found unless @district.company == current_user.company

        if @district.update_attribute(:name, params[:district][:name])
            @district.update_attribute(:country_id, params[:district][:country_id])
            @district.update_attribute(:state_id, params[:district][:state_id])

            Activity.add(self.current_user, Activity::DISTRICT_UPDATED, @district, @district.name)

            flash[:success] = "District updated"
            redirect_to districts_path
        else
            @company = current_user.company
            @countries = Country.all
            @states = State.all
            render 'edit'
        end
    end

    def destroy
        @district = District.find_by_id(params[:id])
        not_found unless @district.company == current_user.company
        @district.destroy

        Activity.add(self.current_user, Activity::DISTRICT_DESTROYED, @district, @district.name)

        flash[:success] = "District destroyed."
        redirect_to districts_path
    end



end
