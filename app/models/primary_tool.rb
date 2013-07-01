class PrimaryTool < ActiveRecord::Base

    validates_uniqueness_of :tool_id, scope: :job_template_id

    belongs_to :tool
    belongs_to :job_template

    has_many :template_documents, class_name: "Document", :conditions => { :template => true }
    has_many :documents, :conditions => { :template => false }

end
