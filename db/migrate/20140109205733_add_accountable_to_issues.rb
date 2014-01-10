class AddAccountableToIssues < ActiveRecord::Migration
    def change
        add_column :issues, :accountable, :boolean, :default => true
    end
end
