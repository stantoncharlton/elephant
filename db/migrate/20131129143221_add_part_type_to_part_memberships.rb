class AddPartTypeToPartMemberships < ActiveRecord::Migration
  def change
    add_column :part_memberships, :part_type, :integer
  end
end
