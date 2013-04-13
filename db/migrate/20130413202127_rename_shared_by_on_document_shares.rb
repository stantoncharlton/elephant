class RenameSharedByOnDocumentShares < ActiveRecord::Migration
  def change
      rename_column :document_shares, :shared_by, :shared_by_id
  end
end
