class AddCurrentShipmentIdToParts < ActiveRecord::Migration
    def change
        add_column :parts, :current_shipment_id, :integer
    end
end
