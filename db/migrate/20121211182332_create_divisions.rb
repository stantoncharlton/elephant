class CreateDivisions < ActiveRecord::Migration
    def change
        create_table :divisions do |t|
            t.string :name
            t.integer :company_id

            t.timestamps
        end

        add_index :divisions, :company_id

    end
end
