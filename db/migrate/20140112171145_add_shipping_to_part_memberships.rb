class AddShippingToPartMemberships < ActiveRecord::Migration
  def change
    add_column :part_memberships, :shipping, :boolean, :default => false
  end
end
