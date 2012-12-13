class Client < ActiveRecord::Base
    attr_accessible :name

    validates :name, presence: true, length: {maximum: 50}
    validates_uniqueness_of :name, :case_sensitive => false
    validates :company, presence: true

    belongs_to :company

    searchable do
        text :name, :as => :code_textp
        time :created_at
        time :updated_at
        integer :company_id

        string :name_sort do
            name
        end
    end


    def self.from_company(company)
        where("company_id = :company_id", company_id: company.id).order("name ASC")
    end


    def self.search(options, company)
        Sunspot.search(Client) do
            fulltext options[:search].present? ? options[:search] : options[:term]
            with(:company_id, company.id)
            order_by :name_sort
            paginate :page => options[:page]
        end
    end

end
