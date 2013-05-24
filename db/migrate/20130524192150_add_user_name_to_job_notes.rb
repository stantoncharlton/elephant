class AddUserNameToJobNotes < ActiveRecord::Migration
  def change
    add_column :job_notes, :user_name, :string
  end
end
