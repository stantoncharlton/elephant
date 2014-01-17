class RigsController < ApplicationController
    before_filter :signed_in_user, only: [:index]
    before_filter :signed_in_user_not_field, only: [:new, :show, :create, ]

    def index
        respond_to do |format|
            format.html { @rigs = Rig.all }
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
        not_found unless @rig.present?
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
