class CreateClients < ActiveRecord::Migration
  def change
    create_table :clients do |t|
      t.string :name
      t.integer :company_id

      t.timestamps
    end

    add_index :clients, :company_id
  end
end
