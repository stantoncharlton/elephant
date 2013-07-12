class CreatePartMemberships < ActiveRecord::Migration
    def change
        create_table :part_memberships do |t|
            t.integer :primary_tool_id
            t.string :material_number, :limit => 30
            t.integer :job_id
            t.integer :part_id
            t.boolean :template, :default => true

            t.timestamps
        end

        add_index :part_memberships, :primary_tool_id
        add_index :part_memberships, :material_number
        add_index :part_memberships, :job_id
    end
end
