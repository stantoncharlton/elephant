class AddDescriptionToJobTemplates < ActiveRecord::Migration
  def change
    add_column :job_templates, :description, :string, :limit => 2000
  end
end
