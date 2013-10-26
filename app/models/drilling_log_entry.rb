class DrillingLogEntry < ActiveRecord::Base
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
    validates_presence_of :drilling_log_id
    validates_presence_of :bha_id
    validates_presence_of :user_id

    belongs_to :company
    belongs_to :user
    belongs_to :drilling_log
    belongs_to :job
    belongs_to :bha


    STANDBY = 0

    SLIDE = 1
    CONNECTION_SURVEY = 2
    ROTATE = 3
    CIRCULATE = 4
    DRILL_CEMENT = 5
    REAMING = 6
    TRIP_IN_HOLE = 7
    TRIP_OUT_HOLE = 8

    RIG_SERVICE = 50
    PICK_UP_BHA = 51
    LAY_DOWN_BHA = 52
    CHANGE_BHA = 53

    WASH = 70
    OTHER = 80


    def self.activity_code_string code
        case code
            when SLIDE
                "Slide"
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
            when WASH
                "Wash"
        end
    end

    def self.options
        options = []
        options << [DrillingLogEntry.activity_code_string(SLIDE), SLIDE]
        options << [DrillingLogEntry.activity_code_string(CONNECTION_SURVEY), CONNECTION_SURVEY]
        options << [DrillingLogEntry.activity_code_string(ROTATE), ROTATE]
        options << [DrillingLogEntry.activity_code_string(CIRCULATE), CIRCULATE]
        options << [DrillingLogEntry.activity_code_string(STANDBY), STANDBY]
        options << [DrillingLogEntry.activity_code_string(TRIP_IN_HOLE), TRIP_IN_HOLE]
        options << [DrillingLogEntry.activity_code_string(TRIP_OUT_HOLE), TRIP_OUT_HOLE]
        options << [DrillingLogEntry.activity_code_string(PICK_UP_BHA), PICK_UP_BHA]
        options << [DrillingLogEntry.activity_code_string(LAY_DOWN_BHA), LAY_DOWN_BHA]
        options << [DrillingLogEntry.activity_code_string(CHANGE_BHA), CHANGE_BHA]
        options << [DrillingLogEntry.activity_code_string(DRILL_CEMENT), DRILL_CEMENT]
        options << [DrillingLogEntry.activity_code_string(REAMING), REAMING]
        options << [DrillingLogEntry.activity_code_string(WASH), WASH]
        options << [DrillingLogEntry.activity_code_string(OTHER), OTHER]
        options
    end

end
