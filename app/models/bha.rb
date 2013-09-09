class Bha < ActiveRecord::Base
    attr_accessible :name,

    acts_as_tenant(:company)

    validates_presence_of :company
    validates_presence_of :document_id
    validates_presence_of :job
    validates_presence_of :name

    belongs_to :company
    belongs_to :document
    belongs_to :job

    has_many :bha_items, :dependent => :destroy, order: "ordering ASC"

end
