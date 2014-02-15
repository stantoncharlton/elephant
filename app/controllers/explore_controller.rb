class ExploreController < ApplicationController
    before_filter :signed_in_user, only: [:index]

    set_tab :explore

    include ExploreHelper

    def index
        not_found unless current_user.role.global_read?

        if request.format == "js"
            case params[:compare].to_i
                when 1
                    rigs_compare
                when 2
                    counties_compare
            end
            return
        end
    end


    def rigs_compare
        if params[:option].to_i == 0
            render 'explore/rigs_all'
        else
            @rig = Rig.find_by_id(params[:option].to_i)
            not_found unless @rig.present?
            render 'explore/rigs_single'
        end
    end

    def counties_compare
        if params[:option].to_i == 0
            render 'explore/counties_all'
        else
            render 'explore/counties_single', :county => params[:option]
        end
    end

end
