class AddNoRedressToPartRedresses < ActiveRecord::Migration
  def change
    add_column :part_redresses, :no_redress, :boolean, :default => false
  end
end
