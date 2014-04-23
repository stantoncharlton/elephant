class AddChargeTypeToPartMemberships < ActiveRecord::Migration
    def change
        add_column :part_memberships, :charge_type, :integer
        add_column :part_memberships, :price, :decimal
    end
end
