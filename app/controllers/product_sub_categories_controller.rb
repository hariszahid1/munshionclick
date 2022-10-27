class ProductSubCategoriesController < ApplicationController
  before_action :set_product_sub_category, only: [:show, :edit, :update, :destroy]
  skip_before_action :verify_authenticity_token

  # GET /product_sub_categories
  # GET /product_sub_categories.json
  def index
    @q = ProductSubCategory.ransack(params[:q])
    if @q.result.count > 0
      @q.sorts = 'id asc' if @q.sorts.empty?
    end
  
    @options_for_select = ProductSubCategory.all
    @product_sub_categories = @q.result(distinct: true).page(params[:page])
    if params[:submit_pdf_staff_with].present?
      if @q.result.count > 0
        @q.sorts = 'created_at desc' if @q.sorts.empty?
      end
      @product_sub_categories=@q.result(distinct: true)
      request.format = 'pdf'
      respond_to do |format|
        format.html
        format.pdf do
          render pdf: 'index_staff_wise',
          layout: 'pdf.html',
          page_size: 'A4',
          margin_top: '0',
          margin_right: '0',
          margin_bottom: '0',
          margin_left: '0',
          encoding: "UTF-8",
          footer:  {             # optional, use 'pdf_plain' for a pdf_plain.html.pdf.erb file, defaults to main layout
            right: '[page] of [topage]'},
          show_as_html: false
        end
      end
    end
  end

  # GET /product_sub_categories/1
  # GET /product_sub_categories/1.json
  def show
  end

  # GET /product_sub_categories/new
  def new
    @product_sub_category = ProductSubCategory.new
    @product_categories = ProductCategory.all
  end

  # GET /product_sub_categories/1/edit
  def edit
    @product_categories = ProductCategory.all
  end

  # POST /product_sub_categories
  # POST /product_sub_categories.json
  def create
    @product_sub_category = ProductSubCategory.new(product_sub_category_params)

    respond_to do |format|
      if @product_sub_category.save
        format.js
        format.html { redirect_to products_url, notice: 'Product sub category was successfully created.' }
        format.json { render :show, status: :created, location: @product_sub_category }
      else
        format.html { render :new }
        format.json { render json: @product_sub_category.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /product_sub_categories/1
  # PATCH/PUT /product_sub_categories/1.json
  def update
    respond_to do |format|
      if @product_sub_category.update(product_sub_category_params)
        format.html { redirect_to product_sub_categories_path, notice: 'Product sub category was successfully updated.' }
        format.json { render :show, status: :ok, location: @product_sub_category }
      else
        format.html { render :edit }
        format.json { render json: @product_sub_category.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /product_sub_categories/1
  # DELETE /product_sub_categories/1.json
  def destroy
    @product_sub_category.destroy
    respond_to do |format|
      format.html { redirect_to new_product_url, notice: 'Product sub category was successfully destroyed.' }
      format.json { head :no_content }
      format.js   { render :layout => false }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_product_sub_category
      @product_sub_category = ProductSubCategory.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def product_sub_category_params
      params.require(:product_sub_category).permit(:product_category_id,:code,:title,:comment)
    end
end
