class PartMembership < ActiveRecord::Base
    attr_accessible :material_number,
                    :template

    validates_presence_of :material_number
    validates_presence_of :primary_tool, :if => :template?
    validates_presence_of :job, :if => :not_template
    validates_presence_of :part, :if => :not_template

    belongs_to :job
    belongs_to :part
    belongs_to :primary_tool

    def not_template
        !self.template?
    end
end
