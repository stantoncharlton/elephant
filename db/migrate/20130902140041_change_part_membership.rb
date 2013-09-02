class ChangePartMembership < ActiveRecord::Migration
  def change
      change_column :part_memberships, :usage, :float
  end

end
