class CreateNoteActivityReports < ActiveRecord::Migration
    def change
        create_table :note_activity_reports do |t|
            t.integer :company_id
            t.integer :note_id
            t.integer :job_id
            t.string :past, :length => 500
            t.string :present, :length => 500
            t.string :future, :length => 500

            t.timestamps
        end

        add_index :note_activity_reports, :note_id
        add_index :note_activity_reports, :job_id
    end
end
