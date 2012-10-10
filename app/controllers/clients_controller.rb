class ClientsController < ApplicationController
    before_filter :signed_in_user, only: [:index, :show]
    before_filter :signed_in_admin, only: [:index, :new, :create, :edit, :update, :destroy]


    def index
        @clients = Client.from_company(current_user.company).paginate(page: params[:page])
    end


    def show
        @client = Client.find(params[:id])
    end

    def new
        @client = Client.new
    end

    def create
        @client = Client.new(params[:client])
        @client.company = current_user.company

        if @client.save
            flash[:success] = "Customer created - #{@client.name}"
            redirect_to clients_path
        else
            render 'new'
        end
    end

    def edit
        @client = Client.find(params[:id])
    end

    def update

        @client = Client.find(params[:id])

        if @client.update_attributes(params[:client])

            flash[:success] = "Customer updated"
            redirect_to clients_path
        else
            render 'edit'
        end
    end

    def destroy
        @client = Client.find(params[:id])
        @client.destroy
        flash[:success] = "Customer deleted."
        redirect_to clients_path
    end

end
