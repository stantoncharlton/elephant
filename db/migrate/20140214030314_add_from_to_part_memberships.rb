class AddFromToPartMemberships < ActiveRecord::Migration
    def change
        add_column :part_memberships, :from_id, :integer
        add_column :part_memberships, :from_type, :string
        add_column :part_memberships, :to_id, :integer
        add_column :part_memberships, :to_type, :string

        add_column :part_memberships, :from_name, :string
        add_column :part_memberships, :to_name, :string
    end
end
