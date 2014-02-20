class Well < ActiveRecord::Base
    attr_accessible :name,
                    :rig_name,
                    :location,
                    :datum,
                    :measured_depth,
                    :measured_depth_value_type,
                    :true_vertical_depth,
                    :true_vertical_depth_value_type,
                    :water_depth,
                    :water_depth_value_type,
                    :offshore,
                    :bottom_hole_temperature,
                    :bottom_hole_temperature_value_type,
                    :bottom_hole_formation_pressure,
                    :bottom_hole_formation_pressure_value_type,
                    :frac_pressure,
                    :frac_pressure_value_type,
                    :max_deviation,
                    :bottom_deviation,
                    :formation,
                    :bottom_hole_location

    acts_as_tenant(:company)

    before_save { |well| well.location = well.location.gsub('°', '').gsub("'", '') }

    validates :name, presence: true, length: {maximum: 50}
    validates_uniqueness_of :name, :case_sensitive => false, scope: :field_id
    validates :company, presence: true
    validates :field, presence: true

    validates :measured_depth, numericality: true, allow_nil: true
    validates :true_vertical_depth, numericality: true, allow_nil: true
    validates :water_depth, numericality: true, allow_nil: true
    validates :bottom_hole_temperature, numericality: true, allow_nil: true
    validates :bottom_hole_formation_pressure, numericality: true, allow_nil: true
    validates :frac_pressure, numericality: true, allow_nil: true
    validates :max_deviation, numericality: true, allow_nil: true
    validates :bottom_deviation, numericality: true, allow_nil: true

    has_one :drilling_log

    def measured_depth=(num)
        num.gsub!(',', '') if num.is_a?(String)
        self[:measured_depth] = num.to_f.round(3)
    end

    def true_vertical_depth=(num)
        num.gsub!(',', '') if num.is_a?(String)
        self[:true_vertical_depth] = num.to_f.round(3)
    end

    def water_depth=(num)
        num.gsub!(',', '') if num.is_a?(String)
        self[:water_depth] = num.to_f.round(3)
    end

    def frac_pressure=(num)
        num.gsub!(',', '') if num.is_a?(String)
        self[:frac_pressure] = num.to_f.round(3)
    end

    def bottom_hole_formation_pressure=(num)
        num.gsub!(',', '') if num.is_a?(String)
        self[:bottom_hole_formation_pressure] = num.to_f.round(3)
    end


    belongs_to :company
    belongs_to :field
    belongs_to :rig

    has_many :jobs, order: "close_date DESC, created_at DESC"


    DATUM_NAD83 = 1
    DATUM_NAD27 = 2

    searchable do
        text :name, :as => :code_textp
        time :created_at
        time :updated_at
        integer :company_id
        integer :field_id

        string :name_sort do
            name
        end
    end

    def self.default_unit_value(field)
        case field
            when "measured_depth"
                return DynamicField::LENGTH_FT
            when "true_vertical_depth"
                return DynamicField::LENGTH_FT
            when "water_depth"
                return DynamicField::LENGTH_FT
            when "bottom_hole_temperature"
                return DynamicField::TEMPERATURE_F
            when "bottom_hole_formation_pressure"
                return DynamicField::PRESSURE_PSI
            when "frac_pressure"
                return DynamicField::PRESSURE_PSI
        end

        DynamicField::STRING
    end

    def dynamic_field(field)
        dynamic_field = DynamicField.new(value_type: Well.default_unit_value(field))
        dynamic_field.set_temporary_value(read_attribute(field.to_sym))
        dynamic_field
    end

    def self.search(options, company)
        Sunspot.search(Well) do
            fulltext options[:search].present? ? options[:search] : options[:term]
            with(:company_id, company.id)
            order_by :name_sort
            paginate :page => options[:page], :per_page => 20
        end
    end

    def self.search_with_field(options, company, field)
        Sunspot.search(Well) do
            fulltext options[:search].present? ? options[:search] : options[:term]
            with(:company_id, company.id)
            if field.present?
                with(:field_id, field.id)
            end
            order_by :name_sort
            paginate :page => options[:page], :per_page => 20
        end
    end

    def x_location
        location_decimal true
    end

    def y_location
        location_decimal false
    end

    private
    def location_decimal(first)
        if !self.location.blank?
            begin
                number = first ? self.location.split(',')[0] : self.location.split(',')[1]
                part = number.split(' ')
                if part.length == 4
                    number = first ? self.location.split(',')[1] : self.location.split(',')[0]
                    part = number.split(' ')
                    decimal = part[0].to_f + (part[1].to_f / 60) + (part[2].to_f / 3600)
                    if part[3].downcase == 'w' || part[3].downcase == 's' || part[3].downcase == 'west' || part[3].downcase == 'south'
                        decimal *= -1
                    end
                    puts "............"
                    puts decimal
                    return decimal
                elsif part.length == 1
                    return number.to_f
                    #part.include?("'")
                end
            rescue
            end
        end

        0.0
    end

end
