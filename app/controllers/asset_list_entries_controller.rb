class AssetListEntriesController < ApplicationController
    before_filter :signed_in_user, only: [:show, :new, :create, :edit, :update, :destroy]

end
