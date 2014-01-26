class ChangeFromToInShipments < ActiveRecord::Migration
    def change
        change_column :shipments, :from_type, :string
        change_column :shipments, :to_type, :string
    end
end
