class AddDocumentSharesCountToDocumentShares < ActiveRecord::Migration
    def change
        add_column :documents, :document_shares_count, :integer, default: 0, null: false
        execute "update documents set document_shares_count=(select count(*) from document_shares where document_id=documents.id)"
    end
end
