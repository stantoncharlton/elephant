class Rig < ActiveRecord::Base
    attr_accessible :name

    acts_as_tenant(:company)

    validates :name, presence: true, length: {maximum: 50}
    validates_uniqueness_of :name, :case_sensitive => false, scope: :company_id
    validates_presence_of :company

    belongs_to :company

    has_many :wells

    searchable do
        text :name, :as => :code_textp
        integer :company_id

        string :name_sort do
            name
        end
    end

    def self.search(options, company)
        Sunspot.search(Rig) do
            fulltext options[:search].present? ? options[:search] : options[:term]
            with(:company_id, company.id)
            order_by :name_sort
            paginate :page => options[:page], :per_page => 20
        end
    end
end
