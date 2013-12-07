class AddPartIdToIssues < ActiveRecord::Migration
  def change
    add_column :issues, :part_id, :integer
    add_column :issues, :part_serial_number, :string
  end
end
