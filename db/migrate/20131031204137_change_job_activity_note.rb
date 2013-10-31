class ChangeJobActivityNote < ActiveRecord::Migration
    def change
        remove_index(:note_activity_reports, :name => 'index_note_activity_reports_on_note_id')
        remove_column :note_activity_reports, :note_id

        add_column :note_activity_reports, :job_note_id, :integer
        add_index :note_activity_reports, :job_note_id

    end
end
