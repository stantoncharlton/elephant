class BhasController < ApplicationController
    before_filter :signed_in_user, only: [:show, :new, :create, :edit, :update, :destroy]

    def show
        if params[:bhas].present? && params[:bhas] == "true"
            @bha = Bha.find_by_id(params[:id])
            not_found unless @bha.company == current_user.company

            @bhas = Bha.where(:document_id => @bha.document.id).order("bhas.created_at ASC")
        else
            @document = Document.find_by_id(params[:id])
            not_found unless @document.company == current_user.company

            @bhas = Bha.where(:document_id => @document.id).order("bhas.created_at ASC")

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
                if params[:tool].starts_with? 'pt_'
                    @primary_tool = PrimaryTool.find_by_id(params[:tool].gsub('pt_', ''))
                    not_found unless @primary_tool.company == current_user.company
                elsif params[:tool].starts_with? 'st_'
                    @secondary_tool = SecondaryTool.find_by_id(params[:tool].gsub('st_', ''))
                    not_found unless @secondary_tool.company == current_user.company
                end
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
                        if (k.starts_with?('pt_tool_') || k.starts_with?('st_tool_')) && v == "1"
                            tool = nil
                            key = k.dup
                            if k.starts_with? 'pt_tool_'
                                id = key.sub! 'pt_tool_', ''
                                tool = PrimaryTool.find_by_id(id)
                            elsif k.starts_with? 'st_tool_'
                                id = key.sub! 'st_tool_', ''
                                tool = SecondaryTool.find_by_id(id)
                            end

                            not_found unless tool.company == current_user.company

                            id = BigDecimal.new(params[k + '_id'])
                            od = BigDecimal.new(params[k + '_od'])
                            length = BigDecimal.new(params[k + '_length'])

                            BhaItem.add(@bha, tool, id, od, length, index)
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
                    if (k.starts_with?('pt_tool_') || k.starts_with?('st_tool_')) && v == "1"
                        tool = nil
                        key = k.dup
                        if k.starts_with? 'pt_tool_'
                            id = key.sub! 'pt_tool_', ''
                            tool = PrimaryTool.find_by_id(id)
                        elsif k.starts_with? 'st_tool_'
                            id = key.sub! 'st_tool_', ''
                            tool = SecondaryTool.find_by_id(id)
                        end

                        not_found unless tool.company == current_user.company

                        id = BigDecimal.new(params[k + '_id'])
                        od = BigDecimal.new(params[k + '_od'])
                        length = BigDecimal.new(params[k + '_length'])

                        BhaItem.add(@bha, tool, id, od, length, index)
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

        @document = @bha.document
        @bha.destroy

        @bhas = Bha.where(:document_id => @document.id).order("bhas.created_at ASC")
        @bha = @bhas.first

        redirect_to bha_path(@document, bha: @bha)
    end

end