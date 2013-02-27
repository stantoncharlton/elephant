class RenameFailureTemplateIdTo < ActiveRecord::Migration
  def up
      rename_column :failures, :failure_template_id, :failure_master_template_id
  end

  def down
  end
end
