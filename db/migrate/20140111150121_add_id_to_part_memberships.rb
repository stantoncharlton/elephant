class AddIdToPartMemberships < ActiveRecord::Migration
    def change
        add_column :part_memberships, :inner_diameter, :decimal
        add_column :part_memberships, :outer_diameter, :decimal
        add_column :part_memberships, :length, :decimal
    end
end
