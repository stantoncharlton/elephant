class AddFromEditableToShipments < ActiveRecord::Migration
  def change
    add_column :shipments, :from_editable, :boolean
  end
end
