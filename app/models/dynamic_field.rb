# encoding: UTF-8

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

    LENGTH = 10
    LENGTH_FT = 11
    LENGTH_IN = 12
    LENGTH_M = 13
    LENGTH_CM = 14
    LENGTH_MM = 15

    TEMPERATURE = 30
    TEMPERATURE_F = 31
    TEMPERATURE_C = 32

    PRESSURE = 40
    PRESSURE_PSI = 41
    PRESSURE_MPA = 42
    PRESSURE_PAS = 43

    RATE = 50
    RATE_BBLS = 51
    RATE_M3 = 52

    VOLUME = 60
    VOLUME_BBLS = 61
    VOLUME_M3 = 62

    AREA = 70
    AREA_IN2 = 71
    AREA_CM2 = 72


    def value
        read_attribute(:value) #.send(value_type_conversion)
    end

    def value_type_unit

        case self.value_type
            when STRING
                ""
            when LENGTH
                ""
            when LENGTH_FT
                "ft"
            when LENGTH_IN
                "in"
            when LENGTH_M
                "m"
            when LENGTH_CM
                "cm"
            when LENGTH_MM
                "mm"
            when TEMPERATURE
                ""
            when TEMPERATURE_F
                "f°"
            when TEMPERATURE_C
                "c°"
            when PRESSURE
                ""
            when PRESSURE_PSI
                "psi"
            when PRESSURE_MPA
                "mpa"
            when PRESSURE_PAS
                "pas"
            when RATE_BBLS
                "bbls/min"
            when RATE_M3
                "m^3/min"
            when VOLUME_BBLS
                "bbls"
            when VOLUME_M3
                "m^3"
            when AREA_IN2
                "in^2"
            when AREA_CM2
                "cm^2"
        end
    end

    def value_type_unit_full

        case self.value_type
            when STRING
                ""
            when LENGTH
                ""
            when LENGTH_FT
                "Feet"
            when LENGTH_IN
                "Inches"
            when LENGTH_M
                "Meters"
            when LENGTH_CM
                "Centimeter"
            when LENGTH_MM
                "Millimeter"
            when TEMPERATURE
                ""
            when TEMPERATURE_F
                "Degrees Fahrenheit"
            when TEMPERATURE_C
                "Degrees Celsius"
            when PRESSURE
                ""
            when PRESSURE_PSI
                "Pounds per Square Inch"
            when PRESSURE_MPA
                "MegaPascal"
            when PRESSURE_PAS
                "Pascal"
            when RATE_BBLS
                "Barrels per Minute"
            when RATE_M3
                "Meters Cubed per Minute"
            when VOLUME_BBLS
                "Barrels"
            when VOLUME_M3
                "Meters Cubed"
            when AREA_IN2
                "Square Inches"
            when AREA_CM2
                "Square Centimeters"
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
            when LENGTH
                "Length: ft | in | m | cm"
            when TEMPERATURE
                "Temperature: f | c"
            when PRESSURE
                "Pressure: psi | Mpa | Pas"
            when RATE
                "Rate: bbls/min | m^3/min"
            when VOLUME
                "Volume: bbls | m^3"
            when AREA
                "Area: in^2 | cm^2"
        end
    end

    def units
        units = Array.new

        units << [get_value_type_label(1), 1]
        units << [get_value_type_label(10), 10]
        units << [get_value_type_label(30), 30]
        units << [get_value_type_label(40), 40]
        units << [get_value_type_label(50), 50]
        units << [get_value_type_label(60), 60]
        units << [get_value_type_label(70), 70]

        units
    end

    def unit_options
        units = get_unit_options(self.dynamic_field_template.value_type)
    end

    def unit_options2
        units = get_unit_options(self.value_type)
    end

    def get_unit_options(value_type)
        units = Array.new

        case value_type
            when LENGTH
                units << ["ft", LENGTH_FT]
                units << ["in", LENGTH_IN]
                units << ["m", LENGTH_M]
                units << ["cm", LENGTH_CM]
            when TEMPERATURE
                units << ["f°", TEMPERATURE_F]
                units << ["c°", TEMPERATURE_C]
            when PRESSURE
                units << ["psi", PRESSURE_PSI]
                units << ["mpa", PRESSURE_MPA]
                units << ["pas", PRESSURE_PAS]
            when RATE
                units << ["bbls/min", RATE_BBLS]
                units << ["m^3/min", RATE_M3]
            when VOLUME
                units << ["bbls", VOLUME_BBLS]
                units << ["m^3", VOLUME_M3]
            when AREA
                units << ["in^2", AREA_IN2]
                units << ["cm^2", AREA_CM2]
        end

        units
    end

    private

    def value_or_attachment
        if !template? && !value?
            errors[:base] << 'Must have value'
        end
    end

end
