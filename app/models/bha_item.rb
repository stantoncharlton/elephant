class BhaItem < ActiveRecord::Base
    attr_accessible :inner_diameter,
                    :outer_diameter,
                    :length,
                    :up,
                    :down


    acts_as_tenant(:company)

    validates :company, presence: true
    validates :bha, presence: true

    belongs_to :company
    belongs_to :bha
    belongs_to :tool, class_name: "PartMembership"


    def self.add(bha, tool, id, od, length, up, down, ordering)

        bha_item = BhaItem.new
        bha_item.bha = bha
        bha_item.company = bha.company
        bha_item.tool = tool
        bha_item.inner_diameter = id
        bha_item.outer_diameter = od
        bha_item.length = length
        bha_item.ordering = ordering
        bha_item.up = up
        bha_item.down = down

        bha_item.save!
        bha_item

    end

    def self.options
        options = []
        options << ["None", 0]
        options << ["", -1]

        options << ["Pin Connections ->", -1]
        options << ["3.5 IF", 1]
        options << ["3.5 REG", 2]
        options << ["4.5 FH", 3]
        options << ["4.5 IF", 4]
        options << ["4.5 REG", 5]
        options << ["4.5 XH", 6]
        options << ["4 FH", 7]
        options << ["4 IF", 8]
        options << ["6.625 REG", 9]
        options << ["NC56", 10]
        options << ["", -1]

        options << ["Box Connections ->", -1]
        options << ["3.5 IF", 11]
        options << ["3.5 REG", 12]
        options << ["4.5 FH", 13]
        options << ["4.5 IF", 14]
        options << ["4.5 REG", 15]
        options << ["4.5 XH", 16]
        options << ["4 FH", 17]
        options << ["4 IF", 18]
        options << ["6.625 REG", 19]
        options << ["NC56", 20]
    end

    def self.connection_string connection
        base_string = ''
        case connection
            when 0
                base_string = "None"
            when 1 || 11
                base_string = "3.5 IF"
            when 2 || 12
                base_string = "3.5 REG"
            when 3 || 13
                base_string = "4.5 FH"
            when 4 || 14
                base_string = "4.5 IF"
            when 5 || 15
                base_string =  "4.5 REG"
            when 6 || 16
                base_string =  "4.5 XH"
            when 7 || 17
                base_string =  "4 FH"
            when 8 || 18
                base_string = "4 IF"
            when 9 || 19
                base_string = "6.625 REG"
            when 10 || 20
                base_string = "NC56"
        end

        if connection == 0
            return base_string
        elsif connection > 10
            return base_string + " P"
        else
            return base_string + " B"
        end
    end

end
