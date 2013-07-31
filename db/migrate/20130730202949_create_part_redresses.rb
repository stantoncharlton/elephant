class CreatePartRedresses < ActiveRecord::Migration
  def change
    create_table :part_redresses do |t|
      t.integer :company_id
      t.integer :part_id
      t.integer :job_id
      t.string :notes

      t.timestamps
    end
  end
end
