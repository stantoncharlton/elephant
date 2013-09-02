class Field < ActiveRecord::Base
    attr_accessible :name,
                    :county

    validates :name, presence: true, length: {maximum: 50}
    validates_uniqueness_of :name, :case_sensitive => false, scope: :district_id
    validates :company, presence: true
    validates :district, presence: true

    belongs_to :company
    belongs_to :district
    belongs_to :country
    belongs_to :state

    has_many :wells, order: "name ASC"

    searchable do
        text :name, :as => :code_textp
        time :created_at
        time :updated_at
        integer :company_id
        integer :district_id

        string :name_sort do
            name
        end
    end


    def self.from_company(company)
        where("company_id = :company_id", company_id: company.id).order("name ASC")
    end

    def jobs(company)
        Job.from_company(company).where(:field_id => self.id)
    end

    def self.search(options, company)
        Sunspot.search(Field) do
            fulltext options[:search].present? ? options[:search] : options[:term]
            with(:company_id, company.id)
            order_by :name_sort
            paginate :page => options[:page], :per_page => 20
        end
    end

end
