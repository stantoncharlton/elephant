class DrillingLog < ActiveRecord::Base
    attr_accessible :comment,
                    :entry_at,
                    :activity_code,
                    :depth,
                    :user_name

    acts_as_tenant(:company)

    validates :comment, length: {minimum: 0, maximum: 500}
    validates :entry_at, presence: true
    validates_presence_of :company_id
    validates_presence_of :job_id
    validates_presence_of :document_id
    validates_presence_of :bha_id
    validates_presence_of :user_id

    belongs_to :company
    belongs_to :user
    belongs_to :document
    belongs_to :job
    belongs_to :bha


    SLIDE = 1
    CONNECTION_SURVEY = 2
    ROTATE = 3
    CIRCULATE = 4
    OTHER = 5
    RIG_SERVICE = 6
    STANDBY = 7
    TRIP_IN_HOLE = 8
    TRIP_OUT_HOLE = 9
    PICK_UP_BHA = 10
    LAY_DOWN_BHA = 11
    CHANGE_BHA = 12
    DRILL_CEMENT = 13
    REAMING = 14

    def self.activity_code_string code
        case code
            when SLIDE
                "Start"
            when CONNECTION_SURVEY
                "Connection & Survey"
            when ROTATE
                "Rotate"
            when CIRCULATE
                "Circulate"
            when OTHER
                "Other"
            when STANDBY
                "Stand-by"
            when TRIP_IN_HOLE
                "Trip in Hole"
            when TRIP_OUT_HOLE
                "Trip Out of Hole"
            when PICK_UP_BHA
                "Pick Up BHA"
            when LAY_DOWN_BHA
                "Lay Down BHA"
            when CHANGE_BHA
                "Change BHA"
            when DRILL_CEMENT
                "Drill Cement"
            when REAMING
                "Reaming"
        end
    end

    def self.options
        options = []
        options << [DrillingLog.activity_code_string(SLIDE), SLIDE]
        options << [DrillingLog.activity_code_string(CONNECTION_SURVEY), CONNECTION_SURVEY]
        options << [DrillingLog.activity_code_string(ROTATE), ROTATE]
        options << [DrillingLog.activity_code_string(CIRCULATE), CIRCULATE]
        options << [DrillingLog.activity_code_string(OTHER), OTHER]
        options << [DrillingLog.activity_code_string(STANDBY), STANDBY]
        options << [DrillingLog.activity_code_string(TRIP_IN_HOLE), TRIP_IN_HOLE]
        options << [DrillingLog.activity_code_string(TRIP_OUT_HOLE), TRIP_OUT_HOLE]
        options << [DrillingLog.activity_code_string(PICK_UP_BHA), PICK_UP_BHA]
        options << [DrillingLog.activity_code_string(LAY_DOWN_BHA), LAY_DOWN_BHA]
        options << [DrillingLog.activity_code_string(CHANGE_BHA), CHANGE_BHA]
        options << [DrillingLog.activity_code_string(DRILL_CEMENT), DRILL_CEMENT]
        options << [DrillingLog.activity_code_string(REAMING), REAMING]
        options
    end

end
