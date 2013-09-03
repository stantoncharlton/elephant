class AddReceivedByNameToPartRedressses < ActiveRecord::Migration
  def change
    add_column :part_redresses, :received_by_name, :string
    add_column :part_redresses, :finished_redress_by_name, :string
  end
end
