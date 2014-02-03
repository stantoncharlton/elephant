class AddTargetToAssetActivities < ActiveRecord::Migration
    def change
        add_column :asset_activities, :target_type, :string
        add_column :asset_activities, :target_id, :integer
    end
end
