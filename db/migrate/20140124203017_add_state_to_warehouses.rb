class AddStateToWarehouses < ActiveRecord::Migration
  def change
    add_column :warehouses, :state, :string
  end
end
