class CreateJobTemplates < ActiveRecord::Migration
  def change
    create_table :job_templates do |t|
      t.string :name
      t.integer :product_line_id
      t.integer :company_id

      t.timestamps
    end

    add_index :job_templates, :product_line_id
    add_index :job_templates, :company_id
  end
end
