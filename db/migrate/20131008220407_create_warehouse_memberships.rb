class CreateWarehouseMemberships < ActiveRecord::Migration
    def change
        create_table :warehouse_memberships do |t|
            t.integer :user_id
            t.integer :company_id
            t.integer :warehouse_id

            t.timestamps
        end

        add_index :warehouse_memberships, :user_id
        add_index :warehouse_memberships, :warehouse_id
        add_index :warehouse_memberships, [:user_id, :warehouse_id], unique: true
    end
end
