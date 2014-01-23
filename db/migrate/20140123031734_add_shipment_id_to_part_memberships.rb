class AddShipmentIdToPartMemberships < ActiveRecord::Migration
    def change
        add_column :part_memberships, :shipment_id, :integer
        add_index :part_memberships, :shipment_id
    end
end
