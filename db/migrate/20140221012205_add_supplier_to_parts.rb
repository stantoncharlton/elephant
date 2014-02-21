class AddSupplierToParts < ActiveRecord::Migration
    def change
        add_column :parts, :supplier_id, :integer
    end
end
