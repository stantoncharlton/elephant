class RigsController < ApplicationController
    before_filter :signed_in_user, only: [:new, :show, :create, :index]

    def index
        respond_to do |format|
            format.html { @rigs = Rig.paginate(page: params[:page], limit: 20) }
            format.js {
                @query = params[:search]
                @rigs = Rig.search(params, current_user.company).results
            }
            format.json {
                if params[:q].present?
                    params[:search] = params[:q]
                end

                @rigs = Rig.search(params, current_user.company).results

                if @rigs.empty?
                    @rigs << Rig.new
                    render json: @rigs.map { |rig| {:value => "No rig found...", :name => "", :id => -1} }
                    return
                end

                if params[:q].present?
                    render json: @rigs.map { |rig| {:name => rig.name, :id => rig.id} }
                else
                    render json: @rigs.map { |rig| {:label => rig.name, :id => rig.id} }
                end
            }
        end

    end


    def show
        @rig = Rig.find(params[:id])
    end

    def new
        @rig = Rig.new
    end

    def create
        @rig = Rig.new(params[:rig])
        @rig.company = current_user.company
        @rig.save
    end

end