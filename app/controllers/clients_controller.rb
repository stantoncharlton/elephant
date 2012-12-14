class ClientsController < ApplicationController
    before_filter :signed_in_user, only: [:index, :show]
    before_filter :signed_in_admin, only: [:new, :create, :edit, :update, :destroy]
    set_tab :clients

    def index

        respond_to do |format|
            format.html { @clients = Client.from_company(current_user.company).paginate(page: params[:page], limit: 10) }
            format.js { @clients = Client.search(params, current_user.company).results }
            format.json {
                if params[:q].present?
                    params[:search] = params[:q]
                end

                @clients = Client.search(params, current_user.company).results

                if params[:q].present?
                    render json: @clients.map { |client| {:name => client.name, :id => client.id} }
                else
                    render json: @clients.map { |client| {:label => client.name, :id => client.id} }
                end
            }
        end

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
