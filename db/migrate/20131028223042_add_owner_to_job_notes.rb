class AddOwnerToJobNotes < ActiveRecord::Migration
    def change
        add_column :job_notes, :owner_id, :integer
        add_column :job_notes, :owner_type, :string
        add_index :job_notes, [:owner_id, :owner_type]
    end
end
