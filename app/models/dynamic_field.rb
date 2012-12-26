class DynamicField < ActiveRecord::Base
    attr_accessible :name,
                    :value_type,
                    :template,
                    :priority

    validates_presence_of :name
    #validates_inclusion_of :value_type_conversion , :in => %w(to_s to_i to_f to_b)
    validates :company, presence: true

    #validate :value_or_attachment

    #before_save :value_or_attachment

    belongs_to :job_template, :conditions => ['dynamic_fields.template = ?', true]
    belongs_to :dynamic_field_template, class_name: "DynamicField"
    belongs_to :job
    belongs_to :company

    STRING = 1
    LENGTH_FT = 2
    LENGTH_IN = 3
    TEMPERATURE = 4
    PRESSURE = 5
    RATE = 6
    VOLUME = 7
    AREA = 8


    def value
        read_attribute(:value) #.send(value_type_conversion)
    end

    def value_type_unit
        case read_attribute(:value_type)
            when STRING
                ""
            when LENGTH_FT
                "ft"
            when LENGTH_IN
                "in"
            when TEMPERATURE
                "f"
            when PRESSURE
                "psi"
            when RATE
                "bbls/min"
            when VOLUME
                "bbls"
            when AREA
                "in2"
        end
    end

    def self.from_company(company)
        where("company_id = :company_id", company_id: company.id).order("name ASC")
    end

    def value_type_label
        get_value_type_label(self.value_type)
    end

    def get_value_type_label(type)
        case type
            when STRING
                "String"
            when LENGTH_FT
                "Length (feet / meters)"
            when LENGTH_IN
                "Length (inches / cm)"
            when TEMPERATURE
                "Temperature (f / c)"
            when PRESSURE
                "Pressure (psi / Mpa)"
            when RATE
                "Rate (bbls/min / m3/min)"
            when VOLUME
                "Volume (bbls)"
            when AREA
                "Area (in2 / cm2)"
        end
    end

    def units
        units = Array.new

        units << [get_value_type_label(1), 1]
        units << [get_value_type_label(2), 2]
        units << [get_value_type_label(3), 3]
        units << [get_value_type_label(4), 4]
        units << [get_value_type_label(5), 5]
        units << [get_value_type_label(6), 6]
        units << [get_value_type_label(7), 7]
        units << [get_value_type_label(8), 8]

        units
    end

    private

    def value_or_attachment
        if !template? && !value?
            errors[:base] << 'Must have value'
        end
    end

end
