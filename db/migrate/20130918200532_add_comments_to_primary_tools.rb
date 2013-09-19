class AddCommentsToPrimaryTools < ActiveRecord::Migration
  def change
    add_column :primary_tools, :comments, :string
  end
end
