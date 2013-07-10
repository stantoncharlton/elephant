class AddActiveToParts < ActiveRecord::Migration
  def change
    add_column :parts, :active, :boolean, :default => true
    add_column :parts, :material_number, :string, :limit => 30
    add_column :parts, :serial_number, :string, :limit => 30
    add_column :parts, :district_serial_number, :string, :limit => 30
    add_column :parts, :total_count, :integer, :default => 0
    add_column :parts, :on_hand_count, :integer, :default => 0
    add_column :parts, :location, :string
    add_column :parts, :total_uses, :integer, :default => 0
  end
end
