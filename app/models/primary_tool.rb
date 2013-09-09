class PrimaryTool < ActiveRecord::Base

    acts_as_tenant(:company)

    validates_uniqueness_of :tool_id, scope: :job_template_id

    belongs_to :tool
    belongs_to :job_template
    belongs_to :company

    has_many :template_documents, class_name: "Document", :conditions => { :template => true }
    has_many :documents, :conditions => { :template => false }

    has_many :part_memberships, dependent: :destroy, foreign_key: "primary_tool_id"

end
