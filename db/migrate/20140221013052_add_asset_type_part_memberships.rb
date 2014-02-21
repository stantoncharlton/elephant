class AddAssetTypePartMemberships < ActiveRecord::Migration
  def change
      add_column :part_memberships, :asset_type, :integer, :default => 0
  end
end
