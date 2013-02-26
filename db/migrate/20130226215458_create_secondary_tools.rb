class CreateSecondaryTools < ActiveRecord::Migration
    def change
        create_table :secondary_tools do |t|
            t.integer :tool_id
            t.integer :job_id

            t.timestamps
        end

        add_index :secondary_tools, :tool_id
        add_index :secondary_tools, :job_id
    end
end
