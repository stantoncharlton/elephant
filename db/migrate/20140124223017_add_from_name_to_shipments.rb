class AddFromNameToShipments < ActiveRecord::Migration
  def change
    add_column :shipments, :from_name, :string
    add_column :shipments, :to_name, :string
  end
end
