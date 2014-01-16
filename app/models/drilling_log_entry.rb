class DrillingLogEntry < ActiveRecord::Base
    attr_accessible :comment,
                    :entry_at,
                    :activity_code,
                    :depth,
                    :user_name,
                    # Drilling Parameters
                    :wob,
                    :flow,
                    :rotary_rpm,
                    :motor_rpm,
                    :spp,
                    :torque,
                    :rotary_weight,
                    :pu_weight,
                    :so_weight,
                    :diff_pressure,
                    :stall,
                    :tfo,
                    # Mud Parameters
                    :mud_type,
                    :mud_weight,
                    :viscosity,
                    :chlorides,
                    :yp,
                    :pv,
                    :ph,
                    :gas,
                    :sand,
                    :solids,
                    :oil,
                    :bh_temp,
                    :fl_temp,
                    :water_loss,
                    #MWD
                    :battery_1_amps,
                    :battery_2_amps,
                    :battery_volts


    acts_as_tenant(:company)

    validates :comment, length: {minimum: 0, maximum: 500}
    validates :entry_at, presence: true
    validates_presence_of :company_id
    validates_presence_of :activity_code
    validates_presence_of :depth
    validates_presence_of :job_id
    validates_presence_of :drilling_log_id
    validates_presence_of :bha_id, :if => :in_hole
    validates_presence_of :user_id

    belongs_to :company
    belongs_to :user
    belongs_to :drilling_log
    belongs_to :job
    belongs_to :bha

    attr_accessor :last_entry

    # In-hole
    DRILLING = 1
    SLIDING = 2
    CIRCULATING = 3
    CONNECTION_SURVEY = 4
    REAMING = 5
    CHANGE_MUD = 6
    POOH = 8
    TIH = 9
    WIRELINE = 10
    WORK_PIPE = 11
    BOP_DRILL = 12
    MWD_SURVEY = 13
    LD_DP = 14
    PU_DP = 15
    DRILLING_CEMENT = 16
    LOGGING = 17
    CONNECTION = 18
    JETTING = 19
    SHORT_TRIP = 20
    CEMENTING = 21

    OTHER = 50
    RIG_REPAIR = 51
    PIPE_STUCK = 52
    FISHING = 53
    RIG_SERVICE_INHOLE = 54
    WAIT_ON_WEATHER = 55

    # Out-hole
    NIPPLE_BOPS = 100
    TEST_BOPS = 103
    CHANGE_BHA = 104


    STANDBY_OUTHOLE = 150
    RIG_SERVICE_OUTHOLE = 151

    def in_hole
        return true if self.activity_code.nil?
        return self.activity_code < 100
    end


    def self.activity_code_string code
        case code
            when DRILLING
                "Rotating"
            when SLIDING
                "Sliding"
            when CIRCULATING
                "Circulating"
            when CONNECTION_SURVEY
                "Connection & Survey"
            when REAMING
                "Reaming"
            when CEMENTING
                "Cementing"
            when CHANGE_MUD
                "Change Mud"
            when CHANGE_BHA
                "Change BHA"
            when POOH
                "POOH (Pull Out of Hole)"
            when SHORT_TRIP
                "Short Trip"
            when TIH
                "TIH (Trip in Hole)"
            when WIRELINE
                "Wireline"
            when WORK_PIPE
                "Work Pipe"
            when BOP_DRILL
                "BOP Drilling"
            when MWD_SURVEY
                "MWD Survey"
            when LD_DP
                "L/D Pipe (Lay Down)"
            when PU_DP
                "P/U Pipe (Pick Up)"
            when DRILLING_CEMENT
                "Drill Cement"
            when LOGGING
                "Logging"
            when CONNECTION
                "Connection"
            when JETTING
                "Jetting"

            when OTHER
                "Undefined - No Other Activity Code (In-hole)"
            when RIG_REPAIR
                "Rig Repair"
            when PIPE_STUCK
                "Pipe Stuck"
            when FISHING
                "Fishing"
            when RIG_SERVICE_INHOLE
                "Rig Service (In-hole)"
            when WAIT_ON_WEATHER
                "Wait on Weather"


            when NIPPLE_BOPS
                "Nipple Up/Down BOPs"
            when TEST_BOPS
                "Test BOPs"

            when STANDBY_OUTHOLE
                "Stand-by (Out-hole)"
            when RIG_SERVICE_OUTHOLE
                "Rig Service (Out-hole)"
        end
    end

    def self.activity_code_color code
        case code
            when DRILLING
                "#00BBCC"
            when SLIDING
                "#223bf2"
            when CIRCULATING
                "#46bfbd"
            when CONNECTION_SURVEY
                "#fdb45c"
            when REAMING
                "#e5dfdb"
            when CEMENTING
                "#c4b6ac"
            when CHANGE_MUD
                "#24bfe0"
            when CHANGE_BHA
                "#bc88d4"
            when POOH
                "#f7464a"
            when SHORT_TRIP
                "#4d5360"
            when TIH
                "#949fb1"
            when WIRELINE
                "#889bd4"
            when WORK_PIPE
                "#404e78"
            when BOP_DRILL
                "#0b7582"
            when MWD_SURVEY
                "#7ce0ec"
            when LD_DP
                "#cfc08c"
            when PU_DP
                "#dbba46"
            when DRILLING_CEMENT
                "#8ccf95"
            when LOGGING
                "#163671"
            when CONNECTION
                "#567bbf"
            when JETTING
                "#d8e7a8"
            when OTHER
                "#121212"
            when RIG_REPAIR
                "#c57765"
            when PIPE_STUCK
                "#d75e33"
            when FISHING
                "Fishing"
            when RIG_SERVICE_INHOLE
                "#f24922"
            when WAIT_ON_WEATHER
                "#fecfbe"
            when NIPPLE_BOPS
                "#d1e8b5"
            when TEST_BOPS
                "#a3bf82"
            when STANDBY_OUTHOLE
                "#9c9998"
            when RIG_SERVICE_OUTHOLE
                "#994527"
            else
                "#6b8cd1"

        end
    end

    def self.options
        options = []
        options << ["** In-hole Activities **", -1]
        options << [DrillingLogEntry.activity_code_string(DRILLING), DRILLING]
        options << [DrillingLogEntry.activity_code_string(SLIDING), SLIDING]
        options << [DrillingLogEntry.activity_code_string(CIRCULATING), CIRCULATING]
        options << [DrillingLogEntry.activity_code_string(CONNECTION_SURVEY), CONNECTION_SURVEY]
        options << [DrillingLogEntry.activity_code_string(CONNECTION), CONNECTION]
        options << [DrillingLogEntry.activity_code_string(REAMING), REAMING]
        options << [DrillingLogEntry.activity_code_string(CEMENTING), CEMENTING]
        options << [DrillingLogEntry.activity_code_string(CHANGE_MUD), CHANGE_MUD]
        options << [DrillingLogEntry.activity_code_string(POOH), POOH]
        options << [DrillingLogEntry.activity_code_string(SHORT_TRIP), SHORT_TRIP]
        options << [DrillingLogEntry.activity_code_string(TIH), TIH]
        options << [DrillingLogEntry.activity_code_string(WIRELINE), WIRELINE]
        options << [DrillingLogEntry.activity_code_string(WORK_PIPE), WORK_PIPE]
        options << [DrillingLogEntry.activity_code_string(BOP_DRILL), BOP_DRILL]
        options << [DrillingLogEntry.activity_code_string(MWD_SURVEY), MWD_SURVEY]
        options << [DrillingLogEntry.activity_code_string(LD_DP), LD_DP]
        options << [DrillingLogEntry.activity_code_string(PU_DP), PU_DP]
        options << [DrillingLogEntry.activity_code_string(DRILLING_CEMENT), DRILLING_CEMENT]
        options << [DrillingLogEntry.activity_code_string(LOGGING), LOGGING]
        options << [DrillingLogEntry.activity_code_string(JETTING), JETTING]


        options << [DrillingLogEntry.activity_code_string(OTHER), OTHER]
        options << [DrillingLogEntry.activity_code_string(RIG_REPAIR), RIG_REPAIR]
        options << [DrillingLogEntry.activity_code_string(PIPE_STUCK), PIPE_STUCK]
        options << [DrillingLogEntry.activity_code_string(FISHING), FISHING]
        options << [DrillingLogEntry.activity_code_string(RIG_SERVICE_INHOLE), RIG_SERVICE_INHOLE]
        options << [DrillingLogEntry.activity_code_string(WAIT_ON_WEATHER), WAIT_ON_WEATHER]


        options << ["", -1]
        options << ["** Out-hole Activities **", -1]

        options << [DrillingLogEntry.activity_code_string(CHANGE_BHA), CHANGE_BHA]
        options << [DrillingLogEntry.activity_code_string(NIPPLE_BOPS), NIPPLE_BOPS]
        options << [DrillingLogEntry.activity_code_string(TEST_BOPS), TEST_BOPS]
        options << [DrillingLogEntry.activity_code_string(STANDBY_OUTHOLE), STANDBY_OUTHOLE]
        options << [DrillingLogEntry.activity_code_string(RIG_SERVICE_OUTHOLE), RIG_SERVICE_OUTHOLE]

        options
    end

end
