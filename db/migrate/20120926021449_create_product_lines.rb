class CreateProductLines < ActiveRecord::Migration
  def change
    create_table :product_lines do |t|
      t.string :name
      t.integer :company_id

      t.timestamps
    end

    add_index :product_lines, :company_id
  end
end
