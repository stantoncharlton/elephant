class CreateIssues < ActiveRecord::Migration
    def change
        create_table :issues do |t|
            t.integer :company_id
            t.integer :job_id
            t.integer :failure_id
            t.integer :status

            t.timestamps
        end
    end
end
