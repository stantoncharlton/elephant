class AddDescriptionToTools < ActiveRecord::Migration
  def change
    add_column :tools, :description, :string
  end
end
