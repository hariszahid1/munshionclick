class ProductCategoriesController < ApplicationController
  include PdfCsvGeneralMethod
  include ProductCategoriesHelper
  before_action :set_product_category, only: [:show, :edit, :update, :destroy]
  skip_before_action :verify_authenticity_token

  require 'tempfile'
  require 'csv'
  # GET /product_categories
  # GET /product_categories.json
  def index
    @q = ProductCategory.ransack(params[:q])
    @q.sorts = 'id asc' if @q.sorts.empty? && @q.result.count.positive?
    @options_for_select = ProductCategory.all
    @product_categories = @q.result.page(params[:page])
    download_product_categories_csv_file if params[:csv].present?
    download_product_categories_pdf_file if params[:pdf].present?
    send_email_file if params[:email].present?
    export_file if params[:export_data].present?
    end

  # GET /product_categories/1
  # GET /product_categories/1.json
  def show
    respond_to do |format|
      format.js
    end
  end

  # GET /product_categories/new
  def new
    @product_category = ProductCategory.new
  end

  # GET /product_categories/1/edit
  def edit
    respond_to do |format|
      format.js
    end
  end

  # POST /product_categories
  # POST /product_categories.json
  def create
    @product_category = ProductCategory.new(product_category_params)

    respond_to do |format|
      if @product_category.save
        format.js
        format.html { redirect_to product_categories_path, notice: 'Product category was successfully created.' }
        format.json { render :show, status: :created, location: @product_category }
      else
        format.html { redirect_to product_categories_path, alert: 'Title is already present!' }
      end
    end
  end

  # PATCH/PUT /product_categories/1
  # PATCH/PUT /product_categories/1.json
  def update
    respond_to do |format|
      if @product_category.update(product_category_params)
        format.html { redirect_to product_categories_url, notice: 'Product category was successfully updated.' }
        format.json { render :show, status: :ok, location: @product_category }
      else
        format.html { redirect_to product_categories_path, alert: 'Title is already present!' }
      end
    end
  end

  # DELETE /product_categories/1
  # DELETE /product_categories/1.json
  def destroy
    @product_category.destroy
    respond_to do |format|
     format.html { redirect_to product_categories_path, notice: 'Product Category was successfully Deleted.' }
      format.json { render :show, status: :ok, location: @product_categories }
    end
  end

  private
  # Use callbacks to share common setup or constraints between actions.
  def set_product_category
    @product_category = ProductCategory.find(params[:id])
  end

  # Never trust parameters from the scary internet, only allow the white list through.
  def product_category_params
    params.require(:product_category).permit(:title,:code,:comment)
  end

  def download_product_categories_csv_file
    @product_categories = @q.result
    header_for_csv = %w[Id Title Comment]
    data_for_csv = get_data_for_product_categories_csv
    generate_csv(data_for_csv, header_for_csv, 'product_categories')
  end

  def download_product_categories_pdf_file
    @product_categories = @q.result
    generate_pdf(@product_categories.as_json, 'Product_Categories', 'pdf.html', 'A4')
  end

  def send_email_file
    EmailJob.perform_later(@q.result.as_json, 'product_categories/index.pdf.erb', params[:email_value],
                           params[:email_choice], params[:subject], params[:body],
                           current_user, 'product_categories')
    if params[:email_value].present?
      flash[:notice] = "Email has been sent to #{params[:email_value]}"
    else
      flash[:notice] = "Email has been sent to #{current_user.email}"
    end
    redirect_to product_categories_path
  end

  def export_file
    export_data('ProductCategory')
  end
end
