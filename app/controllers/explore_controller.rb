class ExploreController < ApplicationController
    before_filter :signed_in_user, only: [:index]

    set_tab :explore

    def index
        not_found unless current_user.role.global_read?

        if request.format == "js"
            if params[:compare].to_i == 1
                if params[:option].to_i == 0
                    render 'explore/rigs_all'
                else
                    @rig = Rig.find_by_id(params[:option].to_i)
                    not_found unless @rig.present?
                    render 'explore/rigs_single'
                end

            end
            return
        end
    end

end
