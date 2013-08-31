class AddRemainingCompanyIds < ActiveRecord::Migration
    def up
        add_column :conversation_memberships, :company_id, :integer
        add_column :document_shares, :company_id, :integer
        add_column :job_memberships, :company_id, :integer
        add_column :messages, :company_id, :integer
        add_column :part_memberships, :company_id, :integer
        add_column :post_job_report_documents, :company_id, :integer
        add_column :primary_tools, :company_id, :integer
        add_column :secondary_tools, :company_id, :integer
        add_column :user_units, :company_id, :integer
    end

    def down
    end
end
