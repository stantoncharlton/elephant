# encoding: UTF-8

class DynamicField < ActiveRecord::Base
    attr_accessible :name,
                    :value_type,
                    :default_value_type,
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
        storage_value_type = get_storage_value_type(read_attribute(:value_type))
        convert(read_attribute(:value), storage_value_type, read_attribute(:value_type))
    end

    def value=(value)
        storage_value_type = get_storage_value_type(read_attribute(:value_type))
        write_attribute(:value, convert(value, read_attribute(:value_type), storage_value_type))
    end

    def value_type
        read_attribute(:value_type)
    end

    def value_type=(value_type)
        storage_value_type = get_storage_value_type(value_type.to_i)

        current_value = self.value
        write_attribute(:value_type, value_type.to_i)

        # Change value in DB if unit changed to non-default
        if storage_value_type != value_type
            write_attribute(:value, convert(current_value, value_type.to_i, storage_value_type))
        elsif
            write_attribute(:value, current_value)
        end
    end

    def convert(value, value_type, new_value_type)

        if value.nil?
            return value
        end

        if value_type == new_value_type or value_type == STRING
            return value
        end

        value = value.to_f

        case value_type
            when LENGTH
                value
            when LENGTH_FT
                case new_value_type
                    when LENGTH_IN
                        value * 12
                    when LENGTH_M
                        value / 3 # Needs Fixed
                    when LENGTH_CM
                        (value / 3) * 10 # Needs Fixed
                end
            when LENGTH_IN
                case new_value_type
                    when LENGTH_FT
                        value / 12
                    when LENGTH_M
                        (value * 12) / 3 # Needs Fixed
                    when LENGTH_CM
                        (value / 3) * 10 # Needs Fixed
                end
            when LENGTH_M
                case new_value_type
                    when LENGTH_FT
                        value * 3
                    when LENGTH_IN
                        (value * 3) / 12 # Needs Fixed
                    when LENGTH_CM
                        value * 10 # Needs Fixed
                end
            when LENGTH_CM
                case new_value_type
                    when LENGTH_FT
                        (value * 10) * 3
                    when LENGTH_IN
                        (value * 3) / 12 # Needs Fixed
                    when LENGTH_M
                        value / 10 # Needs Fixed
                end
            when LENGTH_MM
                0
            when TEMPERATURE
                ""
            when TEMPERATURE_F
                case new_value_type
                    when LENGTH_C
                        value / 2
                end
            when TEMPERATURE_C
                case new_value_type
                    when LENGTH_F
                        value * 2
                end
            when PRESSURE
                ""
            when PRESSURE_PSI
                case new_value_type
                    when PRESSURE_MPA
                        value / 4
                    when PRESSURE_PAS
                        value / 2
                end
            when PRESSURE_MPA
                case new_value_type
                    when PRESSURE_PSI
                        value * 4
                    when PRESSURE_PAS
                        value * 2
                end
            when PRESSURE_PAS
                case new_value_type
                    when PRESSURE_PSI
                        value * 2
                    when PRESSURE_MPA
                        value / 2
                end
            when RATE_BBLS
                case new_value_type
                    when RATE_M3
                        value * 2
                end
            when RATE_M3
                case new_value_type
                    when RATE_BBLS
                        value / 2
                end
            when VOLUME_BBLS
                case new_value_type
                    when VOLUME_M3
                        value * 2
                end
            when VOLUME_M3
                case new_value_type
                    when VOLUME_BBLS
                        value / 2
                end
            when AREA_IN2
                case new_value_type
                    when AREA_CM2
                        value * 2
                end
            when AREA_CM2
                case new_value_type
                    when AREA_IN2
                        value / 2
                end
        end
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
                "Length | Feet"
            when LENGTH_IN
                "Length | Inches"
            when LENGTH_M
                "Length | Meters"
            when LENGTH_CM
                "Length | Centimeters"
            when LENGTH_MM
                "Length | Millimeters"
            when TEMPERATURE
                ""
            when TEMPERATURE_F
                "Temperature | Fahrenheit"
            when TEMPERATURE_C
                "Temperature | Celsius"
            when PRESSURE
                ""
            when PRESSURE_PSI
                "Pressure | PSI"
            when PRESSURE_MPA
                "Pressure | MegaPascals"
            when PRESSURE_PAS
                "Pressure | Pascals"
            when RATE_BBLS
                "Rate | Barrels per Minute"
            when RATE_M3
                "Rate | Meters Cubed per Minute"
            when VOLUME_BBLS
                "Volume | Barrels"
            when VOLUME_M3
                "Volume | Meters Cubed"
            when AREA_IN2
                "Area | Square Inches"
            when AREA_CM2
                "Area | Square Centimeters"
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

        units << ["String", STRING]
        units << ["Length | Feet", LENGTH_FT]
        units << ["Length | Inches", LENGTH_IN]
        units << ["Length | Meters", LENGTH_M]
        units << ["Length | Centimeters", LENGTH_CM]
        units << ["Temperature | Fahrenheit", TEMPERATURE_F]
        units << ["Temperature | Celsius", TEMPERATURE_C]
        units << ["Pressure | PSI", PRESSURE_PSI]
        units << ["Pressure | MegaPascals", PRESSURE_MPA]
        units << ["Pressure | Pascals", PRESSURE_PAS]
        units << ["Rate | Barrels per Minute", RATE_BBLS]
        units << ["Rate | Meters Cubed per Minute", RATE_M3]
        units << ["Volume | Barrels", VOLUME_BBLS]
        units << ["Volume | Meters Cubed", VOLUME_M3]
        units << ["Volume | Meters Cubed", VOLUME_M3]
        units << ["Area | Inches Squared", AREA_IN2]
        units << ["Area | Centimeters Squared", AREA_CM2]

        units
    end

    def unit_options
        get_unit_options(self.dynamic_field_template.value_type)
    end

    def unit_options2
        get_unit_options(self.value_type)
    end

    def get_unit_options(value_type)
        units = Array.new

        case value_type
            when LENGTH_FT, LENGTH_M
                units << ["ft", LENGTH_FT]
                units << ["m", LENGTH_M]
            when LENGTH_IN, LENGTH_CM
                units << ["in", LENGTH_IN]
                units << ["cm", LENGTH_CM]
            when TEMPERATURE_F, TEMPERATURE_C
                units << ["f°", TEMPERATURE_F]
                units << ["c°", TEMPERATURE_C]
            when PRESSURE_PSI, PRESSURE_MPA, PRESSURE_PAS
                units << ["psi", PRESSURE_PSI]
                units << ["mpa", PRESSURE_MPA]
                units << ["pas", PRESSURE_PAS]
            when RATE_BBLS, RATE_M3
                units << ["bbls/min", RATE_BBLS]
                units << ["m^3/min", RATE_M3]
            when VOLUME_BBLS, VOLUME_M3
                units << ["bbls", VOLUME_BBLS]
                units << ["m^3", VOLUME_M3]
            when AREA_IN2, AREA_CM2
                units << ["in^2", AREA_IN2]
                units << ["cm^2", AREA_CM2]
        end

        units
    end

    def get_unit_options_full(value_type)
        units = Array.new

        case value_type
            when LENGTH_FT, LENGTH_M
                units << ["Feet", LENGTH_FT]
                units << ["Meters", LENGTH_M]
            when LENGTH_IN, LENGTH_CM
                units << ["Inches", LENGTH_IN]
                units << ["Centimeters", LENGTH_CM]
            when TEMPERATURE_F, TEMPERATURE_C
                units << ["Fahrenheit", TEMPERATURE_F]
                units << ["Celsius", TEMPERATURE_C]
            when PRESSURE_PSI, PRESSURE_MPA, PRESSURE_PAS
                units << ["PSI", PRESSURE_PSI]
                units << ["MegaPascals", PRESSURE_MPA]
                units << ["Pascals", PRESSURE_PAS]
            when RATE_BBLS, RATE_M3
                units << ["Barrels per Minute", RATE_BBLS]
                units << ["Meters Cubed per Minute", RATE_M3]
            when VOLUME_BBLS, VOLUME_M3
                units << ["Barrels", VOLUME_BBLS]
                units << ["Meters Cubed", VOLUME_M3]
            when AREA_IN2, AREA_CM2
                units << ["Inches Squared", AREA_IN2]
                units << ["Centimeters Squared", AREA_CM2]
        end

        units
    end

    def get_storage_value_type(value_type)
        case value_type
            when LENGTH_FT, LENGTH_M
                LENGTH_FT
            when LENGTH_IN, LENGTH_CM
                LENGTH_IN
            when TEMPERATURE_F, TEMPERATURE_C
                TEMPERATURE_F
            when PRESSURE_PSI, PRESSURE_MPA, PRESSURE_PAS
                PRESSURE_PSI
            when RATE_BBLS, RATE_M3
                RATE_BBLS
            when VOLUME_BBLS, VOLUME_M3
                VOLUME_BBLS
            when AREA_IN2, AREA_CM2
                AREA_IN2
        end
    end

    private

    def value_or_attachment
        if !template? && !value?
            errors[:base] << 'Must have value'
        end
    end

end
