class DrillingLogEntriesController < ApplicationController
    before_filter :signed_in_user, only: [:new, :create, :edit, :update, :destroy]

    def new

    end

    def create
        drilling_log_id = params[:drilling_log_entry][:drilling_log_id]
        params[:drilling_log_entry].delete(:drilling_log_id)

        @drilling_log = DrillingLog.find_by_id(drilling_log_id)

        if params[:file_source].present?

            contents = nil
            file_data = params[:file_source]
            if file_data.respond_to?(:read)
                contents = file_data.read
            elsif file_data.respond_to?(:path)
                contents = File.read(file_data.path)
            else
                logger.error "Bad file_data: #{file_data.class.name}: #{file_data.inspect}"
                return
            end

            spreadsheet = open_spreadsheet(file_data)

            last_bha = nil
            last_date = nil
            last_wob = 0.0
            last_flow = 0.0
            last_rpm = 0.0

            DrillingLogEntry.transaction do

                #Remove Existing Entries
                @drilling_log.drilling_log_entries.each do |dls|
                    dls.destroy
                end

                headers = spreadsheet.row(3)
                (3..spreadsheet.last_row).each do |i|
                    row = spreadsheet.row(i)
                    #if !last_date.blank?
                    #    puts last_date
                    #end
                    #puts row[0]
                    #puts row[1]
                    #puts row[2]
                    #puts row[3]
                    #puts row[4]
                    #puts row[5]

                    drilling_log_entry = DrillingLogEntry.new

                    if !row[0].blank?
                        if row[1].is_a?(Float)
                            time = DateTime.strptime("#{DateTime.new(1899, 12, 30).to_f + row[1].to_f}", '%s')
                            drilling_log_entry.entry_at = Time.strptime("#{row[0]} #{time.strftime("%l:%M %p")} #{Time.zone.name}", '%Y-%m-%d %l:%M %p %Z')
                        else
                            drilling_log_entry.entry_at = Time.strptime("#{row[0]} 24:00 #{Time.zone.name}", '%Y-%m-%d %k:%M %Z')
                        end
                        last_date = row[0]
                    else
                        if row[1].is_a?(Float)
                            time = DateTime.strptime("#{DateTime.new(1899, 12, 30).to_f + row[1].to_f}", '%s')
                            drilling_log_entry.entry_at = Time.strptime("#{last_date} #{time.strftime("%l:%M %p")} #{Time.zone.name}", '%Y-%m-%d %l:%M %p %Z')
                        else
                            drilling_log_entry.entry_at = Time.strptime("#{last_date} 24:00 #{Time.zone.name}", '%Y-%m-%d %k:%M %Z')
                        end
                    end

                    puts  drilling_log_entry.entry_at.in_time_zone(Time.zone).strftime("%H:%M %p")

                    drilling_log_entry.depth = row[2]
                    drilling_log_entry.comment = row[5]
                    drilling_log_entry.activity_code = get_activity_code(row[4])
                    drilling_log_entry.drilling_log = @drilling_log
                    drilling_log_entry.company = current_user.company
                    drilling_log_entry.job = @drilling_log.document.job
                    drilling_log_entry.user = current_user
                    drilling_log_entry.user_name = current_user.name
                    if !row[3].blank?
                        bha = Bha.includes(document: {job: :well}).where("wells.id = ?", @drilling_log.job.well_id).where("bhas.name = ?", row[3].to_i.to_s).first
                        if bha.nil?
                            bha = Bha.new
                            bha.name = row[3].to_i.to_s
                            bha.company = current_user.company
                            bha.document = Document.includes(job: :well).where(:document_type => Document::BOTTOM_HOLE_ASSEMBLY).where("wells.id = ?", @drilling_log.job.well_id).last
                            bha.job = @drilling_log.job
                            bha.save
                        end
                        drilling_log_entry.bha = bha
                        last_bha = bha
                    elsif !last_bha.nil?
                        drilling_log_entry.bha = last_bha
                    end

                    if !row[6].blank?
                        drilling_log_entry.wob = row[6].to_d
                        last_wob = drilling_log_entry.wob
                    else
                        drilling_log_entry.wob = last_wob
                    end
                    if !row[7].blank?
                        drilling_log_entry.flow = row[7].to_d
                        last_flow = drilling_log_entry.flow
                    else
                        drilling_log_entry.flow = last_flow
                    end
                    if !row[8].blank?
                        drilling_log_entry.rotary_rpm = row[8].to_d
                        last_rpm = drilling_log_entry.rotary_rpm
                    else
                        drilling_log_entry.rotary_rpm = last_rpm
                    end

                    drilling_log_entry.save
                end
            end

            @drilling_log = DrillingLog.find_by_id(drilling_log_id)
            @drilling_log.recalculate

            redirect_to drilling_log_path(@drilling_log, anchor: :log)
            return
        else

            bha_id = params[:drilling_log_entry][:bha_id]
            params[:drilling_log_entry].delete(:bha_id)

            depth = params[:drilling_log_entry][:depth]
            params[:drilling_log_entry].delete(:depth)

            override_date = nil
            if params[:drilling_log_entry][:override_date] == "1"
                override_date = Time.strptime("#{params[:date]} #{params[:hour]}:#{params[:minute]} #{Time.zone.utc_offset}", '%m/%d/%Y %H:%M %z')
            end

            params[:drilling_log_entry].delete(:override_date)

            @drilling_log_entry = DrillingLogEntry.new(params[:drilling_log_entry])
            @drilling_log_entry.drilling_log = @drilling_log
            @drilling_log_entry.company = current_user.company
            @drilling_log_entry.job = @drilling_log.document.job
            @drilling_log_entry.user = current_user
            @drilling_log_entry.user_name = current_user.name
            @drilling_log_entry.depth = depth.gsub(',' '')
            if !bha_id.blank?
                @bha = Bha.find_by_id(bha_id)
                @drilling_log_entry.bha = @bha
            end


            if override_date.nil?
                @drilling_log_entry.entry_at = Time.now
            else
                @drilling_log_entry.entry_at = override_date
            end

            @last_entry = @drilling_log.drilling_log_entries.last
        end


        @drilling_log_entry.save

        @drilling_log.recalculate

        if @drilling_log_entry.bha.present?
            @drilling_log_entry.bha.delay.update_usage
        end

        if @last_entry.nil?
            @last_entry = @drilling_log_entry
        end
    end

    def edit

    end

    def update

    end

    def destroy
        @drilling_log_entry = DrillingLogEntry.find_by_id(params[:id])
        not_found unless @drilling_log_entry.present?
        @drilling_log_entry.destroy
        @drilling_log_entry.drilling_log.recalculate
    end


    private
    def open_spreadsheet(file)
        case File.extname(file.original_filename)
            when ".csv" then
                Roo::Csv.new(file.path, nil, :ignore)
            when ".xls" then
                Roo::Excel.new(file.path, nil, :ignore)
            when ".xlsx" then
                Roo::Excelx.new(file.path, nil, :ignore)
            else
                raise "Unknown file type: #{file.original_filename}"
        end
    end

    def get_activity_code value
        case value.upcase
            when "DRILLING"
                DrillingLogEntry::DRILLING
            when "SLIDING"
                DrillingLogEntry::SLIDING
            when "CIRCULATING"
                DrillingLogEntry::CIRCULATING
            when "CONNECTION & SURVEY"
                DrillingLogEntry::CONNECTION_SURVEY
            when "REAMING"
                DrillingLogEntry::REAMING
            when "CEMENTING"
                DrillingLogEntry::CEMENTING
            when "CHANGE MUD"
                DrillingLogEntry::CHANGE_MUD
            when "CHANGE BHA"
                DrillingLogEntry::CHANGE_BHA
            when "POOH"
                DrillingLogEntry::POOH
            when "SHORT TRIP"
                DrillingLogEntry::SHORT_TRIP
            when "TIH"
                DrillingLogEntry::TIH
            when "WIRELINE"
                DrillingLogEntry::WIRELINE
            when "WORK PIPE"
                DrillingLogEntry::WORK_PIPE
            when "BOP DRILL"
                DrillingLogEntry::BOP_DRILL
            when "MWD SURVEY"
                DrillingLogEntry::MWD_SURVEY
            when "L/D DP"
                DrillingLogEntry::LD_DP
            when "P/U DP"
                DrillingLogEntry::PU_DP
            when "DRILLING CEMENT"
                DrillingLogEntry::DRILLING_CEMENT
            when "LOGGING"
                DrillingLogEntry::LOGGING
            when "CONNECTION"
                DrillingLogEntry::CONNECTION
            when "JETTING"
                DrillingLogEntry::JETTING

            when "UNDEFINED"
                DrillingLogEntry::OTHER
            when "RIG REPAIR"
                DrillingLogEntry::RIG_REPAIR
            when "PIPE STUCK"
                DrillingLogEntry::PIPE_STUCK
            when "FISHING"
                DrillingLogEntry::FISHING
            when "RIG SERVICE INHOLE"
                DrillingLogEntry::RIG_SERVICE_INHOLE
            when "WAIT ON WEATHER"
                DrillingLogEntry::WAIT_ON_WEATHER


            when "NIPPLE U/D BOPS"
                DrillingLogEntry::NIPPLE_BOPS
            when "TEST BOPS"
                DrillingLogEntry::TEST_BOPS

            when "STANDBY"
                DrillingLogEntry::STANDBY_OUTHOLE
            when "RIG SERVICE OUTHOLE"
                DrillingLogEntry::RIG_SERVICE_OUTHOLE

            else
                DrillingLogEntry::OTHER
        end
    end
end
