class Shipment < ActiveRecord::Base
    attr_accessible :accepted_at,
                    :status,
                    :from_name,
                    :to_name

    acts_as_tenant(:company)


    validates :company, presence: true
    validates :district, presence: true
    validates :user, presence: true
    #validates :from, presence: true
    #validates :to, presence: true

    belongs_to :company
    belongs_to :district
    belongs_to :user
    belongs_to :accepted_by, class_name: 'User'

    belongs_to :from, :polymorphic => true
    belongs_to :to, :polymorphic => true

    has_many :part_memberships, order: "name ASC", :dependent => :destroy
    has_many :job_notes

    AWAITING_SHIPMENT = 1
    IN_TRANSIT = 2
    COMPLETE = 3

    WAREHOUSE = 1
    SUPPLIER = 2
    JOB = 3

end
