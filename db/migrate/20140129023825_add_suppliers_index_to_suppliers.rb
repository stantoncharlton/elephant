class AddSuppliersIndexToSuppliers < ActiveRecord::Migration
  def change
      add_index :suppliers, :company_id
      add_index :survey_points, :company_id
      add_index :surveys, :company_id
      add_index :user_units, :company_id

      add_index :warehouse_memberships, :company_id
      add_index :shipments, :company_id
      add_index :rigs, :company_id
      add_index :rig_memberships, :company_id

      add_index :part_redresses, :company_id
      add_index :part_redresses, :part_id
      add_index :part_redresses, :job_id


      add_index :part_memberships, :company_id
      add_index :note_activity_reports, :company_id
      add_index :messages, :company_id
      add_index :job_notes, :company_id
      add_index :job_memberships, :company_id

      add_index :document_shares, :company_id
      add_index :document_revisions, :company_id
      add_index :conversation_memberships, :company_id

  end
end
