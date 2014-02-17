class ExploreController < ApplicationController
    before_filter :signed_in_user, only: [:index]

    set_tab :insight

    include ExploreHelper

    def index
        not_found unless current_user.role.global_read?

        if request.format == "js"
            @time_range = params[:time_range]
            @option = params[:option]
            case params[:compare].to_i
                when 1
                    rigs_compare
                when 2
                    counties_compare
                when 3
                    assets_compare
            end
            return
        end
    end


    def rigs_compare

        if params[:option].to_i == 0
            if @time_range.to_i == 1
                render 'explore/rigs/rigs_all'
            elsif @time_range.to_i == 2
                render 'explore/rigs/rigs_all_name'
            end
        else
            @rig = Rig.find_by_id(params[:option].to_i)
            not_found unless @rig.present?
            render 'explore/rigs/rigs_single'
        end

    end

    def assets_compare
        if @time_range.to_i == 1
            render 'explore/assets/assets_all_name'
        elsif @time_range.to_i == 2
            render 'explore/assets/assets_all_name'
        end
    end

    def counties_compare
        if params[:option] == '0'
            render 'explore/counties_all'
        else
            @county = params[:option]
            render 'explore/county_single'
        end
    end

end
