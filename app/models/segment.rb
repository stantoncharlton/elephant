class Segment < ActiveRecord::Base
  attr_accessible :name

  acts_as_tenant(:company)

  validates :name, presence: true, length: {maximum: 50}
  validates_uniqueness_of :name, :case_sensitive => false, scope: :division_id
  validates_presence_of :company
  validates_presence_of :division

  belongs_to :division
  belongs_to :company

  has_many :product_lines, dependent: :destroy, order: "name ASC"

  searchable do
      text :name, :as => :code_textp
      integer :company_id
  end

  def self.from_company(company)
      where("company_id = :company_id", company_id: company.id)
  end

  def jobs
      self.company.jobs.joins(job_template: {product_line: :segment}).where("segments.id = ?", self.id)
  end

  def active_jobs
    Job.where("jobs.company_id = ?", self.company_id).where(:status => Job::ACTIVE).includes(job_template: {product_line: :segment}).where("segments.id = ?", self.id)
  end

  def self.from_company_for_user(segment, options, user, company)
      Sunspot.search(Job) do
          with(:segment_id, segment.id)
          any_of do
              if user.role.limit_to_assigned_jobs?
                  with(:job_membership, user.id)
              elsif user.role.limit_to_district?
                  with(:district_id, user.district.id)
              elsif user.role.limit_to_product_line? && !user.product_line.nil?
                  with(:product_line_id, user.product_line.id)
              end
          end
          with(:company_id, company.id)
          order_by :created_at, :desc
          paginate :page => options[:page]
      end
  end
end
