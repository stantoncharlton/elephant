class CreateFailures < ActiveRecord::Migration
    def change
        create_table :failures do |t|
            t.string :text
            t.integer :company_id
            t.string :reference
            t.integer :product_line_id
            t.integer :job_template_id
            t.integer :job_id
            t.boolean :template, :default => false

            t.timestamps
        end

        add_index :failures, :company_id
        add_index :failures, :product_line_id
        add_index :failures, :job_template_id
        add_index :failures, :job_id
    end
end
