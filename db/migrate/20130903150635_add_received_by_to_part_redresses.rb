class AddReceivedByToPartRedresses < ActiveRecord::Migration
  def change
    add_column :part_redresses, :received_by, :integer
    add_column :part_redresses, :finished_redress_by, :integer
  end
end
