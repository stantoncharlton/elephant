class AddWeightToUserUnits < ActiveRecord::Migration
  def change
    add_column :user_units, :weight, :integer
    add_column :user_units, :weight_casing, :integer
    add_column :user_units, :weight_gradient, :integer
  end
end
