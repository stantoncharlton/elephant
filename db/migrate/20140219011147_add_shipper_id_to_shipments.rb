class AddShipperIdToShipments < ActiveRecord::Migration
  def change
    add_column :shipments, :shipper_id, :integer
  end
end
