class ProductCategoriesController < ApplicationController
  include PdfCsvGeneralMethod
  include ProductCategoriesHelper
	before_action :check_access
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
    @custom_pagination = params[:limit].present? ? params[:limit] : 25
    @custom_pagination = @pos_setting.custom_pagination['product_categories'] if @pos_setting&.custom_pagination.present? && @pos_setting&.custom_pagination['product_categories'].present?
    @product_categories = @q.result.page(params[:page]).per(@custom_pagination)

    if params[:csv].present?
      request.format = 'csv'
      download_product_categories_csv_file
    end
    download_product_categories_pdf_file if params[:pdf].present?
    send_email_file if params[:email].present?
    if params[:export_data].present?
      request.format = 'csv'
      export_file
    end

    @total_categories_count = Product.joins(:product_category).group("product_categories.title").count
    @total_sub_categories_count = ProductSubCategory.joins(:product_category).group('product_categories.title').count

    @category_title = @total_categories_count.keys.map { |a| a.gsub(' ', '-') }
    @category_unit = @total_categories_count.values
    @category_sub_unit = @total_sub_categories_count.values

    respond_to do |format|
      format.pdf
      format.csv
      format.js
      format.html
    end
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
        notice_text = 'Product category was successfully created.'
        notice_text = 'Unit category was successfully created.' if pos_setting_sys_type.eql? 'HousingScheme'
        format.html { redirect_to product_categories_path, notice: notice_text }
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
        notice_text = 'Product category was successfully updated.'
        notice_text = 'Unit category was successfully updated.' if pos_setting_sys_type.eql? 'HousingScheme'
        format.html { redirect_to product_categories_url, notice: notice_text }
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
      notice_text = 'Product category was successfully Deleted.'
      notice_text = 'Unit category was successfully Deleted.' if pos_setting_sys_type.eql? 'HousingScheme'
      format.html { redirect_to product_categories_path, notice: notice_text }
      format.json { render :show, status: :ok, location: @product_category }
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
    generate_csv(data_for_csv, header_for_csv, "ProductCategories-Total-#{@product_categories.count}-#{DateTime.now.strftime("%d-%m-%Y-%H-%M")}")
  end

  def download_product_categories_pdf_file
    @product_categories = @q.result
    generate_pdf(@product_categories.as_json, "ProductCategories-Total-#{@product_categories.count}-#{DateTime.now.strftime("%d-%m-%Y-%H-%M")}",
                 'pdf.html', 'A4', false, 'product_categories/index.pdf.erb')
  end

  def send_email_file
    EmailJob.perform_later(@q.result.as_json, 'product_categories/index.pdf.erb', params[:email_value],
                           params[:email_choice], params[:subject], params[:body],
                           current_user, "ProductCategories-Total-#{@q.result.count}-#{DateTime.now.strftime("%d-%m-%Y-%H-%M")}")
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
