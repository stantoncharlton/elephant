class UsersController < ApplicationController
    before_filter :signed_in_user, only: [:index, :show, :settings]
    before_filter :signed_in_admin, only: [:new, :create, :destroy, :edit, :update]
    set_tab :users

    def index

        respond_to do |format|
            format.html { @users = User.search(params[:search]).from_company(current_user.company).paginate(page: params[:page], limit: 10) }
            format.json {
                @users = User.where("company_id = :company_id", company_id: current_user.company.id).where("lower(name) like ?", "%#{params[:term].downcase}%").order("name desc")
                render json: @users.map { |user| { :label => user.name, :position_title => user.position_title, :district => user.district.present? ? user.district.name : "", :id => user.id } }
            }
        end
    end

    def settings
        @user = current_user
    end

    def show
        @user = User.find(params[:id])
        not_found unless @user.company == current_user.company

        @activities = Activity.activities_for_user(@user).paginate(page: params[:page], limit: 10)
    end


    def edit
        @user = User.find(params[:id])
        not_found unless @user.company == current_user.company
        @districts = current_user.company.districts
    end

    def update

        @user = User.find(params[:id])
        not_found unless @user.company == current_user.company

        User.transaction do
            if @user.update_attribute(:location, params[:user][:location])
                @user.update_attribute(:position_title, params[:user][:position_title])
                @user.update_attribute(:phone_number, params[:user][:phone_number])
                @user.update_attribute(:district_id, params[:user][:district_id])

                Activity.add(self.current_user, Activity::USER_UPDATED, @user, @user.name)
                flash[:success] = "User updated"
                redirect_to users_path
            else
                @districts = current_user.company.districts
                render 'edit'
            end
        end
    end

    def new
        store_location

        @user = User.new
        @districts = current_user.company.districts
    end

    def create
        district_id = params[:user][:district_id]
        params[:user].delete(:district_id)

        @user = User.new(params[:user])
        @districts = current_user.company.districts
        @user.company = current_user.company
        @user.district = District.find(district_id)
        password = SecureRandom.urlsafe_base64[1..7]
        @user.password = password
        @user.password_confirmation = password
        @user.create_password = true

        if @user.save

            Activity.add(self.current_user, Activity::USER_CREATED, @user, @user.name)

            flash[:success] = "User created - #{@user.email}"
            redirect_to users_path
        else
            render 'new'
        end
    end

    def destroy
        @user = User.find(params[:id])
        not_found unless @user.company == current_user.company

        if !current_user?(@user)
            User.find(params[:id]).destroy

            Activity.add(self.current_user, Activity::USER_DESTROYED, @user, @user.name)
            flash[:success] = "User destroyed."
            redirect_to users_path
        else
            flash[:error] = "Can't delete yourself."
            redirect_to users_path
        end
    end
end
