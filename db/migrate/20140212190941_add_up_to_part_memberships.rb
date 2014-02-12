class AddUpToPartMemberships < ActiveRecord::Migration
  def change
    add_column :part_memberships, :up, :integer
    add_column :part_memberships, :down, :integer
  end
end
