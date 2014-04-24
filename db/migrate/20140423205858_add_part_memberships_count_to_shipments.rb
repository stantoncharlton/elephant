class AddPartMembershipsCountToShipments < ActiveRecord::Migration
  def change
    add_column :shipments, :part_memberships_count, :integer
  end
end
