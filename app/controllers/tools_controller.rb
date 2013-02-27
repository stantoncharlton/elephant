class ToolsController < ApplicationController
    before_filter :signed_in_admin, only: [:new, :create, :update, :destroy]

    def new
        @tool = Tool.new
        @tool.company = current_user.company
        if params[:product_line]
            @tool.product_line = ProductLine.find_by_id params[:product_line]
        elsif params[:division]
            @tool.division = Division.find_by_id params[:division]
        end
    end

    def create
        product_line_id = params[:tool][:product_line_id]
        params[:tool].delete(:product_line_id)

        division_id = params[:tool][:division_id]
        params[:tool].delete(:division_id)

        @tool = Tool.new(params[:tool])
        @tool.company = current_user.company

        if !product_line_id.blank?
            @tool.product_line = ProductLine.find_by_id product_line_id
            @tool.save
        elsif !division_id.blank?
            @tool.division = Division.find_by_id division_id
            @tool.save
        end
    end

    def update

    end

    def destroy
        @tool = Tool.find_by_id(params[:id])
        not_found unless  @tool.company == current_user.company
        @tool.destroy
    end

end
