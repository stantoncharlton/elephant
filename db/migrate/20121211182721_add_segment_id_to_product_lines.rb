class AddSegmentIdToProductLines < ActiveRecord::Migration
  def change
    add_column :product_lines, :segment_id, :integer
  end
end
