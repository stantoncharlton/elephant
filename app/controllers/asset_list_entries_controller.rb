class AssetListEntriesController < ApplicationController
    before_filter :signed_in_user, only: [:show, :new, :create, :edit, :update, :destroy]

    def show

    end

    def new

    end

    def create
        asset_list_id = params[:asset_list_entry][:asset_list_id]
        params[:asset_list_entry].delete(:asset_list_id)

        @asset_list_entry = AssetListEntry.new(params[:asset_list_entry])
        @asset_list_entry.company = current_user.company
        @asset_list_entry.user = current_user
        @asset_list = AssetList.find_by_id(asset_list_id)
        @asset_list_entry.asset_list = @asset_list
        @asset_list_entry.save
    end

    def edit

    end

    def update

    end

    def destroy
        @asset_list_entry = AssetListEntry.find_by_id(params[:id])
        not_found unless @asset_list_entry.present?
        @asset_list_entry.destroy
    end

end
