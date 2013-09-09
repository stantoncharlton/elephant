class BhaItem < ActiveRecord::Base
    attr_accessible :inner_diameter,
                    :outer_diameter,
                    :length,
                    :tool_type



    acts_as_tenant(:company)

    validates :company, presence: true
    validates :bha, presence: true

    belongs_to :company
    belongs_to :bha
    belongs_to :tool, :polymorphic => true


    def self.add(bha, tool, id, od, length, ordering)

        bha_item = BhaItem.new
        bha_item.bha = bha
        bha_item.tool = tool
        bha_item.inner_diameter = id
        bha_item.outer_diameter = od
        bha_item.length = length
        bha_item.ordering = ordering

        bha_item.save!
        bha_item

    end

end
