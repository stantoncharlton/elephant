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
                @bha.name = old_bha.name + " Clone " + SecureRandom.urlsafe_base64[1..7].to_s
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
            not_found unless @document.company == current_user.company

            @job = @document.job
        end
    end

    def create
        document_id = params[:bha][:document_id]
        params[:bha].delete(:document_id)

        @bha = Bha.new(params[:bha])
        @bha.company = current_user.company
        @bha.document = Document.find_by_id(document_id)
        not_found unless @bha.document.company == current_user.company
        @bha.job = @bha.document.job
        @document = @bha.document
        @job = @bha.job

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
                            down = params[k + '_down']

                            BhaItem.add(@bha, tool, id, od, length, up, down, index)
                            index = index + 1
                        end
                    end
                end

                redirect_to bha_path(@document, bha: @bha)
            else
                render 'new'
            end
        end
    end

    def edit
        @bha = Bha.find_by_id(params[:id])
        not_found unless @bha.company == current_user.company

        @document = @bha.document
        @job = @bha.job
    end


    def update
        @bha = Bha.find_by_id(params[:id])
        not_found unless @bha.company == current_user.company

        @document = @bha.document
        @job = @bha.job

        Bha.transaction do
            if @bha.update_attribute(:name, params[:bha][:name])
                @bha.update_attribute(:description, params[:bha][:description])

                @bha.bha_items.each do |i|
                    i.destroy
                end

                index = 0
                params[:bha_items].each do |k, v|
                    if v == "1"
                        tool = PartMembership.find_by_id(k)
                        not_found unless tool.company == current_user.company

                        id = BigDecimal.new(params[k + '_id'])
                        od = BigDecimal.new(params[k + '_od'])
                        length = BigDecimal.new(params[k + '_length'])
                        up = params[k + '_up']
                        down = params[k + '_down']

                        BhaItem.add(@bha, tool, id, od, length, up, down, index)
                        index = index + 1
                    end
                end

                redirect_to bha_path(@document, bha: @bha)
            else
                render 'edit'
            end
        end
    end


    def destroy
        @bha = Bha.find_by_id(params[:id])
        not_found unless @bha.company == current_user.company

        if DrillingLogEntry.where(:bha_id => @bha.id).count == 0
            @document = @bha.document
            @bha.destroy

            @bhas = Bha.where(:document_id => @document.id).order("bhas.created_at ASC")
            @bha = @bhas.first

            redirect_to bha_path(@document, bha: @bha)
        else
            errors.add(:base, "This BHA is associated with Drilling Log entries and therefore can't be deleted.")
            redirect_to bha_path(@document, bha: @bha)
        end
    end

end