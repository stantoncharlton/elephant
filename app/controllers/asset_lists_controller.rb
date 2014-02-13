class AssetListsController < ApplicationController
    before_filter :signed_in_user, only: [:index, :show]

    def index
        if params[:document].present?
            @document = Document.find_by_id(params[:document])
            not_found unless !@document.nil?

            @asset_list = AssetList.where(:document_id => @document.id).last
            if @asset_list.nil?
                @asset_list = AssetList.new
                @asset_list.company = current_user.company
                @asset_list.document = @document
                @asset_list.job = @document.job
                @asset_list.user = current_user
                @asset_list.save
            end

            redirect_to @asset_list
            return
        end

        not_found
    end

    def show
        @asset_list = AssetList.find_by_id(params[:id])
        not_found unless @asset_list.present?

        respond_to do |format|
            format.html {

            }
            format.xlsx {
                excel = drilling_log_to_excel @drilling_log
                send_data excel.to_stream.read, :filename => "Daily Activity.xlsx", :type => "application/vnd.openxmlformates-officedocument.spreadsheetml.sheet"
            }
        end

    end

end
