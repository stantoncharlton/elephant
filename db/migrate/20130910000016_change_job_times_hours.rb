class ChangeJobTimesHours < ActiveRecord::Migration
  def change
      change_column :job_times, :hours, :decimal
  end

end
