class AddMaterialNumberIndexToParts < ActiveRecord::Migration
    def change
        add_index :parts, :material_number
        add_index :parts, :serial_number
        add_index :parts, :district_serial_number
    end
end
