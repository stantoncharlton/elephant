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

        ConversationMembership.reset_column_information
        ConversationMembership.find_each do |p|
            p.update_attribute(:company_id, p.user.company_id)
        end

        DocumentShare.reset_column_information
        DocumentShare.find_each do |p|
            p.update_attribute(:company_id, p.shared_by.company_id)
        end

        JobMembership.reset_column_information
        JobMembership.find_each do |p|
            p.update_attribute(:company_id, p.job.company_id)
        end

        Message.reset_column_information
        Message.find_each do |p|
            p.update_attribute(:company_id, p.user.company_id)
        end

        PartMembership.reset_column_information
        PartMembership.find_each do |p|
            if p.primary_tool.present?
                p.update_attribute(:company_id, p.primary_tool.company_id)
            else
                p.update_attribute(:company_id, p.job.company_id)
            end
        end

        PostJobReportDocument.reset_column_information
        PostJobReportDocument.find_each do |p|
            p.update_attribute(:company_id, p.job_template.company_id)
        end

        PrimaryTool.reset_column_information
        PrimaryTool.find_each do |p|
            p.update_attribute(:company_id, p.tool.company_id)
        end

        SecondaryTool.reset_column_information
        SecondaryTool.find_each do |p|
            p.update_attribute(:company_id, p.tool.company_id)
        end

        UserUnit.reset_column_information
        UserUnit.find_each do |p|
            p.update_attribute(:company_id, p.user.company_id)
        end
    end

    def down
    end
end
