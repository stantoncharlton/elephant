class AddSerialToSecondaryTools < ActiveRecord::Migration
  def change
    add_column :secondary_tools, :serial_number, :string
    add_column :secondary_tools, :received, :boolean, :default => false

    add_column :job_templates, :track_accessories, :boolean, :default => false
  end
end
