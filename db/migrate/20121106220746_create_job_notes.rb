class CreateJobNotes < ActiveRecord::Migration
  def change
    create_table :job_notes do |t|
      t.integer :job_id
      t.integer :user_id
      t.integer :company_id
      t.string :text
      t.integer :note_type

      t.timestamps
    end
  end
end
