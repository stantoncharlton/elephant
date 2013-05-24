class JobMembership < ActiveRecord::Base
    attr_accessible :job_role_id,
                    :user_name

    belongs_to :user
    belongs_to :job

    validates :user, presence: true
    validates :job, presence: true

    #validates_uniqueness_of :user_id, scope: :job_id

    validates :job_role_id, presence: true


    OBSERVER = 1
    MANAGER = 2
    COORDINATOR = 3
    FIELD = 4
    SHOP = 5
    CREATOR = 6


    def role_title
       case self.job_role_id
           when OBSERVER
               "Observer"
           when MANAGER
               "Manager"
           when COORDINATOR
               "Coordinator"
           when FIELD
               "Field"
           when SHOP
               "Shop"
           when CREATOR
               "Creator"
           else
               "-"
       end
    end

end
