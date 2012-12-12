class Segment < ActiveRecord::Base
  attr_accessible :name

  validates :name, presence: true, length: {maximum: 50}
  validates_uniqueness_of :name, :case_sensitive => false, scope: :division_id
  validates_presence_of :company
  validates_presence_of :division

  belongs_to :division
  belongs_to :company

  has_many :product_lines, dependent: :destroy, order: "name ASC"


  def self.from_company(company)
      where("company_id = :company_id", company_id: company.id)
  end
end
