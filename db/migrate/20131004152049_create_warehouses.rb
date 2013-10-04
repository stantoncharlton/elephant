class CreateWarehouses < ActiveRecord::Migration
    def change
        create_table :warehouses do |t|
            t.integer :company_id
            t.integer :district_id
            t.string :name
            t.string :location

            t.timestamps
        end

        add_index :warehouses, :company_id
        add_index :warehouses, :district_id
    end
end
