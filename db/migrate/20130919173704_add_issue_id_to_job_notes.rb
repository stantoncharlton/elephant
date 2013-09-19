class AddIssueIdToJobNotes < ActiveRecord::Migration
  def change
    add_column :job_notes, :issue_id, :integer
  end
end
