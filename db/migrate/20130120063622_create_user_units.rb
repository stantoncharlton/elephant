class CreateUserUnits < ActiveRecord::Migration
  def change
    create_table :user_units do |t|
      t.integer :user_id
      t.integer :length_outer
      t.integer :length_inner
      t.integer :temperature
      t.integer :pressure
      t.integer :rate
      t.integer :volume
      t.integer :area

      t.timestamps
    end

    add_index :user_units, :user_id
  end
end
