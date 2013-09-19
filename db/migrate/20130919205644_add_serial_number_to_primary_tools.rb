class AddSerialNumberToPrimaryTools < ActiveRecord::Migration
  def change
    add_column :primary_tools, :serial_number, :string
    add_column :primary_tools, :received, :boolean, :default => false
    add_column :primary_tools, :simple_tracking, :boolean, :default => false
  end
end
