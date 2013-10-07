class AddWarehouseIdToParts < ActiveRecord::Migration
  def change
    add_column :parts, :warehouse_id, :integer
  end
end
