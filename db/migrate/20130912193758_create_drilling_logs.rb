class CreateDrillingLogs < ActiveRecord::Migration
    def change
        create_table :drilling_logs do |t|
            t.integer :company_id
            t.integer :document_id
            t.integer :job_id

            t.timestamps
        end

        add_index :drilling_logs, :company_id
        add_index :drilling_logs, :document_id
        add_index :drilling_logs, :job_id
    end
end
