class AddReceivedAtToPartRedresss < ActiveRecord::Migration
    def change
        add_column :part_redresses, :received_at, :datetime
        add_column :part_redresses, :finished_redress_at, :datetime
    end
end
