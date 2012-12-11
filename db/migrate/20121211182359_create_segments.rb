class CreateSegments < ActiveRecord::Migration
    def change
        create_table :segments do |t|
            t.string :name
            t.integer :company_id
            t.integer :division_id

            t.timestamps
        end

        add_index :segments, :company_id
        add_index :segments, :division_id

    end
end
