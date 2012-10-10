class DynamicField < ActiveRecord::Base
    attr_accessible :name,
                    :value_type_conversion,
                    :template

    validates_presence_of :name
    validates_inclusion_of :value_type_conversion, :in => %w(to_s to_i to_f)
    validate :value_or_attachment

    before_save :value_or_attachment

    def value
        read_attribute(:value).send(value_type_conversion)
    end


private

    def value_or_attachment
        if !template? && !value?
            errors[:base] << 'Must have value'
        end
    end

end
