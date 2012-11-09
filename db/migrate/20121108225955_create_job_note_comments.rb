class CreateJobNoteComments < ActiveRecord::Migration
    def change
        create_table :job_note_comments do |t|
            t.integer :job_id
            t.integer :job_note_id
            t.integer :user_id
            t.string :text
            t.integer :company_id

            t.timestamps
        end

        add_index :job_note_comments, :job_note_id
        add_index :job_note_comments, :company_id
        add_index :job_note_comments, :user_id
        add_index :job_note_comments, :job_id
    end
end
