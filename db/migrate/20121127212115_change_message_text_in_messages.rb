class ChangeMessageTextInMessages < ActiveRecord::Migration
  def up
      change_column :messages, :text, :text, :limit => 2000
      change_column :job_notes, :text, :text, :limit => 2000
      change_column :job_note_comments, :text, :text, :limit => 1000
  end

  def down
  end
end
