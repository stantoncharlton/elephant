class AddTrackUsageToPartMemberships < ActiveRecord::Migration
  def change
    add_column :part_memberships, :track_usage, :boolean
    add_column :part_memberships, :usage, :integer
  end
end
