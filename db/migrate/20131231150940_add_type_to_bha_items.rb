class AddTypeToBhaItems < ActiveRecord::Migration
  def change
    add_column :bha_items, :tool_type, :integer
  end
end
