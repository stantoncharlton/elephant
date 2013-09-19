class AddTemplateToPrimaryTools < ActiveRecord::Migration
  def change
    add_column :primary_tools, :template, :boolean, :default => true
  end
end
