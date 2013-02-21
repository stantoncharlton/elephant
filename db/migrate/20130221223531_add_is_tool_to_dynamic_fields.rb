class AddIsToolToDynamicFields < ActiveRecord::Migration
  def change
    add_column :dynamic_fields, :is_tool, :boolean
  end
end
