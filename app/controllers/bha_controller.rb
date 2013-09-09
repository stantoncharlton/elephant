class BhaController < ApplicationController
    before_filter :signed_in_user, only: [:show, :edit, :update, :destroy]

    def show
        if params[:bha].present? && params[:bha] == "true"
            @bha = Bha.find_by_id(params[:id])
            not_found unless @bha.company == current_user.company

            @bhas = Bha.where(:document_id => @bha.document.id).order("bhas.created_at ASC")
        else
            @document = Document.find_by_id(params[:id])
            not_found unless @document.company == current_user.company

            @bhas = Bha.where(:document_id => @document.id).order("bhas.created_at ASC")
            @bha = @bhas.first
        end
    end

    def edit
        @document = Document.find_by_id(params[:document])
        not_found unless @document.company == current_user.company

        @bha = Bha.find_by_id(params[:id])

        if @bha.present?
            not_found unless @bha.company == current_user.company
        else
            @bha = Bha.new
        end

    end


    def update

        if params[:bha_id].present? && !params[:bha_id].blank?
            @bha = Bha.find_by_id(params[:bha_id])
        else
            @bha = Bha.new(name: params[:name])
            @document = Document.find_by_id(params[:id])
            not_found unless @document.company == current_user.company
        end

        Bha.transaction do
            @bha.company = current_user.company
            @bha.document = @document
            @bha.job = @document.job

            if @bha.save
                index = 0
                params[:bha].each do |k, v|
                    if v == "1"
                        tool = nil
                        key = k.dup
                        if k.starts_with? 'pt_tool_'
                            id = key.sub! 'pt_tool_', ''
                            tool = PrimaryTool.find_by_id(id)
                        elsif k.starts_with? 'st_tool_'
                            id = key.sub! 'pt_tool_', ''
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
            else
                puts @bha.errors.full_messages.join(', ').html_safe
            end
        end

        @bhas = Bha.where(:document_id => @document.id).order("bhas.created_at ASC")
    end


    def destroy
        @bha = Bha.find_by_id(params[:id])
        not_found unless @bha.company == current_user.company

        @document = @bha.document
        @bha.destroy

        @bhas = Bha.where(:document_id => @document.id).order("bhas.created_at ASC")
        @bha = @bhas.first
    end

end