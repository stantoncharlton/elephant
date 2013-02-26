class CreateTools < ActiveRecord::Migration
    def change
        create_table :tools do |t|
            t.string :name
            t.integer :company_id
            t.integer :division_id
            t.integer :product_line_id

            t.timestamps
        end

        add_index :tools, :company_id
        add_index :tools, :division_id
        add_index :tools, :product_line_id
    end
end
