class AddJobToPrimaryTools < ActiveRecord::Migration
  def change
    add_column :primary_tools, :job_id, :integer
  end
end
