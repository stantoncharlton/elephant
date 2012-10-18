class UsersController < ApplicationController
    before_filter :signed_in_user, only: [:show, :settings]
    before_filter :signed_in_admin, only: [:index, :new, :create, :destroy, :edit, :update]

    def index

        @users = User.search(params[:search]).from_company(current_user.company).paginate(page: params[:page], limit: 10)
    end

    def settings
        @user = current_user
    end

    def show
        @user = User.find(params[:id])
        not_found unless @user.company == current_user.company
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

        User.transaction do
            @user = User.new(params[:user])
            @districts = current_user.company.districts
            @user.company = current_user.company
            @user.district = District.find(district_id)
            password = SecureRandom.urlsafe_base64[1..7]
            @user.password = password
            @user.password_confirmation = password
            @user.create_password = true

            if @user.save
                flash[:success] = "User created - #{@user.email}"
                redirect_to users_path
            else
                render 'new'
            end
        end
    end

    def destroy
        @user = User.find(params[:id])
        not_found unless @user.company == current_user.company

        if !current_user?(@user)
            User.find(params[:id]).destroy
            flash[:success] = "User destroyed."
            redirect_to users_path
        else
            flash[:error] = "Can't delete yourself."
            redirect_to users_path
        end
    end
end
