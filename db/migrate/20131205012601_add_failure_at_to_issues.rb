class AddFailureAtToIssues < ActiveRecord::Migration
  def change
    add_column :issues, :failure_at, :datetime
  end
end
