class AddIndexesToIssues < ActiveRecord::Migration
    def change
        add_index :issues, :company_id
        add_index :issues, :failure_id
        add_index :issues, :job_id
    end
end
