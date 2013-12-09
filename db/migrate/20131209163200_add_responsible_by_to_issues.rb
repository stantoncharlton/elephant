class AddResponsibleByToIssues < ActiveRecord::Migration
  def change
    add_column :issues, :responsible_by_id, :integer
    add_column :issues, :responsible_by_name, :string
  end
end
