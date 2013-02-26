class CreatePrimaryTools < ActiveRecord::Migration
    def change
        create_table :primary_tools do |t|
            t.integer :tool_id
            t.integer :job_template_id

            t.timestamps
        end

        add_index :primary_tools, :tool_id
        add_index :primary_tools, :job_template_id
    end
end
