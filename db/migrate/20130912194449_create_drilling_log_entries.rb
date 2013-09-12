class CreateDrillingLogEntries < ActiveRecord::Migration
    def change
        create_table :drilling_log_entries do |t|
            t.integer :company_id
            t.integer :drilling_log_id
            t.integer :user_id
            t.string :user_name
            t.datetime :entry_at
            t.decimal :depth
            t.integer :activity_code
            t.string :comment
            t.integer :bha_id
            t.decimal :usage_hours

            t.timestamps
        end

        add_index :drilling_logs, :company_id
        add_index :drilling_logs, :drilling_log_id
        add_index :drilling_logs, :user_id
        add_index :drilling_logs, :bha_id
    end
end
