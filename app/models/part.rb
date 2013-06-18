class Part < ActiveRecord::Base
    attr_accessible :name,
                    :part_number,
                    :status,
                    :template

    validates_presence_of :part_number
    validates_presence_of :name, :if => :template?
    validates_presence_of :master_part, :if => :not_template

    belongs_to :district
    belongs_to :current_job
    belongs_to :master_part
    belongs_to :primary_tool

    def not_template
        !self.template?
    end
end
