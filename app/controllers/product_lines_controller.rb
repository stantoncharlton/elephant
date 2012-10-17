class ProductLinesController < ApplicationController
    before_filter :signed_in_admin, only: [:new, :create, :edit, :update, :destroy]

    respond_to :js


    def new
        @product_line = ProductLine.new
    end

    def create
        @product_line = ProductLine.new(params[:product_line])
        @product_line.company = current_user.company

        if @product_line.save
            flash[:success] = "Product Line created - #{@product_line.name}"
            #redirect_to job_template_path_path
        else
            render 'error'
        end
    end

    def edit
        @product_line = ProductLine.find(params[:id])
        not_found unless @product_line.company == current_user.company
    end

    def update

        @product_line = ProductLine.find(params[:id])
        not_found unless @product_line.company == current_user.company

        if @product_line.update_attributes(params[:product_line])

            flash[:success] = "Product Line updated"
            #redirect_to job_templates_path
        else
            render 'edit'
        end
    end

    def destroy
        @product_line = ProductLine.find(params[:id])
        not_found unless @product_line.company == current_user.company
        @product_line.destroy
        flash[:success] = "Product Line deleted."
    end
end
