class RenameRatingOnJobs < ActiveRecord::Migration
  def up
      rename_column :jobs, :rating, :performance_rating
  end

  def down
  end
end
