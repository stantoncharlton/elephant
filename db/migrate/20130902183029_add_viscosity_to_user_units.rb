class AddViscosityToUserUnits < ActiveRecord::Migration
  def change
    add_column :user_units, :viscosity, :integer
  end
end
