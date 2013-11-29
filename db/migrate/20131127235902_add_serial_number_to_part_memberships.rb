class AddSerialNumberToPartMemberships < ActiveRecord::Migration
  def change
      add_column :part_memberships, :name, :string
      add_column :part_memberships, :serial_number, :string
      add_column :part_memberships, :received, :boolean, :default => false
      add_column :part_memberships, :received_at, :datetime
      add_column :part_memberships, :received_by, :integer
  end
end
