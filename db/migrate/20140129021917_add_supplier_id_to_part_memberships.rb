class AddSupplierIdToPartMemberships < ActiveRecord::Migration
    def change
        add_column :part_memberships, :supplier_id, :integer
    end
end
