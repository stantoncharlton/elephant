class BhasController < ApplicationController
    before_filter :signed_in_user, only: [:show, :new, :create, :edit, :update, :destroy]

    def show
        if params[:bhas].present? && params[:bhas] == "true"
            @bha = Bha.find_by_id(params[:id])
            not_found unless @bha.present? && @bha.company == current_user.company

            @bhas = Bha.includes(document: {job: :well}).where("wells.id = ?", @bha.document.job.well_id).order("bhas.created_at ASC")
        else
            @document = Document.find_by_id(params[:id])
            not_found unless !@document.nil? && @document.company == current_user.company

            @bhas = Bha.includes(document: {job: :well}).where("wells.id = ?", @document.job.well_id).order("bhas.created_at ASC")

            if params[:bha].present?
                @bha = Bha.find_by_id(params[:bha])
                not_found unless @bha.company == current_user.company
            else
                @bha = @bhas.first
            end
        end
    end

    def new
        if params[:tool].present?
            @document = Document.find_by_id(params[:document])
            if !@document.nil?
                not_found unless @document.company == current_user.company
                @part_membership = PartMembership.find_by_id(params[:tool])
            end
        elsif params[:clone].present? && params[:clone] == "true"
            old_bha = Bha.find_by_id(params[:bha])
            not_found unless old_bha.company == current_user.company
            Bha.transaction do
                @bha = Bha.new
                @bhas = Bha.includes(document: {job: :well}).where("wells.id = ?", old_bha.document.job.well_id).order("bhas.name ASC")
                @bha.name = (@bhas.last.name.to_i + 1).to_s
                @bha.company = current_user.company
                @bha.document = old_bha.document
                @bha.job = old_bha.job
                @bha.save

                old_bha.bha_items.each do |item|
                    new_item = BhaItem.new
                    new_item.bha = @bha
                    new_item.company = current_user.company
                    new_item.tool = item.tool
                    new_item.inner_diameter = item.inner_diameter
                    new_item.outer_diameter = item.outer_diameter
                    new_item.length = item.length
                    new_item.ordering = item.ordering
                    new_item.up = item.up
                    new_item.down = item.down
                    new_item.save
                end

                redirect_to edit_bha_path(@bha)
            end
        else
            @bha = Bha.new

            @document = Document.find_by_id(params[:document])
            @job = @document.job

            if params[:bha].present?
                @master_bha = Bha.find(params[:bha])
            end
        end
    end

    def create
        document_id = params[:bha][:document_id]
        params[:bha].delete(:document_id)

        master_bha_id = params[:bha][:master_bha_id]
        params[:bha].delete(:master_bha_id)

        @bha = Bha.new(params[:bha])
        @bha.company = current_user.company
        @bha.document = Document.find_by_id(document_id)
        @bha.job = @bha.document.job
        @document = @bha.document
        @job = @bha.job
        if !master_bha_id.blank?
            @master_bha = Bha.find_by_id(master_bha_id)
            @bha.master_bha = @master_bha
            @bha.name = @bha.master_bha.name + ' - Tool String'
        end

        Bha.transaction do
            if @bha.save
                index = 0
                if params[:bha_items].present?
                    params[:bha_items].each do |k, v|
                        if v == "1"
                            tool = PartMembership.find_by_id(k)
                            not_found unless tool.company == current_user.company

                            id = BigDecimal.new(params[k + '_id'])
                            od = BigDecimal.new(params[k + '_od'])
                            length = BigDecimal.new(params[k + '_length'])
                            up = params[k + '_up']
                            asset_type = params[k + '_asset_type']
                            down = params[k + '_down']

                            BhaItem.add(@bha, tool, id, od, length, up, down, asset_type, index)
                            index = index + 1
                        end
                    end
                end

                @bha.delay.create_activity(current_user, Activity::CREATE_BHA)

                @drilling_log = DrillingLog.joins(document: {job: :well}).where("jobs.well_id = ?", @bha.document.job.well_id).first
                redirect_to drilling_log_path(@drilling_log, anchor: "drilling-bha", bha: @bha.master_bha.present? ? @bha.master_bha : @bha)
            else
                render 'new'
            end
        end
    end

    def edit
        @bha = Bha.find_by_id(params[:id])
        @document = @bha.document
        @job = @bha.job

        @master_bha = @bha.master_bha
    end


    def update
        @bha = Bha.find_by_id(params[:id])
        not_found unless @bha.company == current_user.company

        @document = @bha.document
        @job = @bha.job

        Bha.transaction do
            if params[:bha].present? && params[:bha][:name].present?
                passed = @bha.update_attribute(:name, params[:bha][:name])
            else
                passed = true
            end
            if passed
                if params[:bha].present? && params[:bha][:name].present?
                    @bha.update_attribute(:description, params[:bha][:description])
                    @bha.update_attribute(:bit_to_sensor, params[:bha][:bit_to_sensor])
                    @bha.update_attribute(:bit_to_gamma, params[:bha][:bit_to_gamma])
                end

                @bha.bha_items.each do |i|
                    i.destroy
                end

                index = 0
                if params[:bha_items].present? && params[:bha_items].any?
                    params[:bha_items].each do |k, v|
                        if v == "1"
                            tool = PartMembership.find_by_id(k)
                            not_found unless tool.company == current_user.company

                            id = BigDecimal.new(params[k + '_id'])
                            od = BigDecimal.new(params[k + '_od'])
                            length = BigDecimal.new(params[k + '_length'])
                            up = params[k + '_up']
                            asset_type = params[k + '_asset_type']
                            down = params[k + '_down']

                            BhaItem.add(@bha, tool, id, od, length, up, down, asset_type, index)
                            index = index + 1
                        end
                    end
                end

                @bha.delay.update_usage
                @bha.delay.create_activity(current_user, Activity::UPDATE_BHA)


                @drilling_log = DrillingLog.joins(document: {job: :well}).where("jobs.well_id = ?", @bha.document.job.well_id).first
                redirect_to drilling_log_path(@drilling_log, anchor: "drilling-bha", bha: @bha.master_bha.present? ? @bha.master_bha : @bha)
            else
                render 'edit'
            end
        end
    end


    def destroy
        @bha = Bha.find_by_id(params[:id])
        @original_bha = @bha
        @document = @bha.document
        not_found unless @bha.company == current_user.company

        if DrillingLogEntry.where(:bha_id => @bha.id).count == 0
            @bha.destroy

            @bhas = Bha.where(:document_id => @document.id).order("bhas.created_at ASC")
            @bha = @bhas.first
        else
            flash[:error] = "This BHA is attached to log entries and therefore can't be deleted. Delete the log if you really want to continue."
        end

        @original_bha.create_activity(current_user, Activity::DELETE_BHA)

        @drilling_log = DrillingLog.joins(document: {job: :well}).where("jobs.well_id = ?", @original_bha.document.job.well_id).first
        redirect_to drilling_log_path(@drilling_log, anchor: "drilling-bha", bha: @bha.present? && @bha.master_bha.present? ? @bha.master_bha : @bha)
    end

end