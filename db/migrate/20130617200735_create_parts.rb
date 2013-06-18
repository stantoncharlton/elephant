class CreateParts < ActiveRecord::Migration
    def change
        create_table :parts do |t|
            t.string :name
            t.string :part_number
            t.boolean :template, :default => false
            t.integer :master_part_id
            t.integer :status
            t.integer :current_job_id
            t.integer :primary_tool_id

            t.timestamps
        end

        add_index :parts, :part_number
    end
end
