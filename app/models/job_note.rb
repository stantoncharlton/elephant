class JobNote < ActiveRecord::Base
    attr_accessible :note_type,
                    :text

    validates_presence_of :company_id
    validates_presence_of :user_id
    validates_presence_of :job_id
    validates_presence_of :note_type
    validates_presence_of :text


    belongs_to :company
    belongs_to :user
    belongs_to :job


end