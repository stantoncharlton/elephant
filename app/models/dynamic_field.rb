class DynamicField < ActiveRecord::Base
    attr_accessible :name,
                    :value_type_conversion,
                    :template,
                    :priority

    validates_presence_of :name
    validates_inclusion_of :value_type_conversion, :in => %w(to_s to_i to_f to_b)
    #validate :value_or_attachment

    #before_save :value_or_attachment

    belongs_to :job_template, :conditions => ['dynamic_fields.template = ?', true]
    belongs_to :dynamic_field_template, class_name: "DynamicField"
    belongs_to :job
    belongs_to :company

    def value
        read_attribute(:value)#.send(value_type_conversion)
    end

    def value_type
        if  value_type_conversion == 'to_s'
            return "String"
        elsif  value_type_conversion == 'to_i' || value_type_conversion == 'to_f'
            return "Number"
        else
            return "Boolean"
        end

    end

    def self.from_company(company)
        where("company_id = :company_id", company_id: company.id).order("name ASC")
    end

private

    def value_or_attachment
        if !template? && !value?
            errors[:base] << 'Must have value'
        end
    end

end
