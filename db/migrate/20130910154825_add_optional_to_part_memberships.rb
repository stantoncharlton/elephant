class AddOptionalToPartMemberships < ActiveRecord::Migration
  def change
    add_column :part_memberships, :optional, :boolean, :default => false
  end
end
