class ClientsController < ApplicationController
    before_filter :signed_in_user, only: [:index, :show]
    before_filter :signed_in_admin, only: [:index, :new, :create, :edit, :update, :destroy]
    set_tab :clients

    def index
        @clients = Client.from_company(current_user.company).paginate(page: params[:page])
    end


    def show
        @client = Client.find(params[:id])
        not_found unless @client.company == current_user.company

        @jobs = Job.from_client(@client)
    end

    def new
        @client = Client.new
    end

    def create
        @client = Client.new(params[:client])
        @client.company = current_user.company

        if @client.save

            Activity.add(self.current_user, Activity::CLIENT_CREATED, @client, @client.name)
            flash[:success] = "Customer created - #{@client.name}"
            redirect_to clients_path
        else
            render 'new'
        end
    end

    def edit
        @client = Client.find(params[:id])
        not_found unless @client.company == current_user.company
    end

    def update

        @client = Client.find(params[:id])
        not_found unless @client.company == current_user.company

        if @client.update_attributes(params[:client])

            Activity.add(self.current_user, Activity::CLIENT_UPDATED, @client, @client.name)
            flash[:success] = "Customer updated"
            redirect_to clients_path
        else
            render 'edit'
        end
    end

    def destroy
        @client = Client.find(params[:id])
        not_found unless @client.company == current_user.company

        Activity.add(self.current_user, Activity::CLIENT_DESTROYED, @client, @client.name)
        @client.destroy
        flash[:success] = "Customer deleted."
        redirect_to clients_path
    end

end
