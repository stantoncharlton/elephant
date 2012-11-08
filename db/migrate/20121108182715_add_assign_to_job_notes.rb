class AddAssignToJobNotes < ActiveRecord::Migration
  def change
    add_column :job_notes, :assign_to_id, :integer
  end
end
