class ChangeMessageLengthOnTables < ActiveRecord::Migration
  def up
      change_column :messages, :text, :string, :limit => 2000
      change_column :job_notes, :text, :string, :limit => 2000
      change_column :job_note_comments, :text, :string, :limit => 1000
  end

  def down
  end
end
