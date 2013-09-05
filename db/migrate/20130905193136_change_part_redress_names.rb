class ChangePartRedressNames < ActiveRecord::Migration
  def change
      rename_column :part_redresses, :received_by, :received_by_id
      rename_column :part_redresses, :finished_redress_by, :finished_redress_by_id
  end

end
