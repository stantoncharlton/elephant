class AddUserNameToJobNoteComments < ActiveRecord::Migration
  def change
    add_column :job_note_comments, :user_name, :string
  end
end
