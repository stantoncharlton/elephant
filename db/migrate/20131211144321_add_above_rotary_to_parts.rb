class AddAboveRotaryToParts < ActiveRecord::Migration
  def change
    add_column :parts, :below_rotary, :decimal
    add_column :parts, :above_rotary, :decimal
  end
end
