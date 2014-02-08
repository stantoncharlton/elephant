class AddWeightToParts < ActiveRecord::Migration
  def change
    add_column :parts, :weight, :decimal
  end
end
