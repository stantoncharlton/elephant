class JobMembership < ActiveRecord::Base
    attr_accessible :job_role_id

    belongs_to :user
    belongs_to :job

    validates :user_id, presence: true
    validates :job_id, presence: true

    #validates_uniqueness_of :user_id, scope: :job_id

    validates :job_role_id, presence: true


    def role_title
       case self.job_role_id
           when 1
               "Observer"
           when 2
               "Supervisor"
           when 3
               "Coordinator"
           when 4
               "Field"
           when 5
               "Shop"
           when 6
               "Creator"
           else
               "-"
       end
    end

end
