class ProductSubCategoriesController < ApplicationController
  include PdfCsvGeneralMethod
  include ProductSubCategoriesHelper
	before_action :check_access
  before_action :set_product_sub_category, only: [:show, :edit, :update, :destroy]
  skip_before_action :verify_authenticity_token
  require 'tempfile'
  require 'csv'
  # GET /product_sub_categories
  # GET /product_sub_categories.json
  def index
    @q = ProductSubCategory.includes(:product_category).joins(:product_category).ransack(params[:q])
    @q.sorts = 'id asc' if @q.sorts.empty? && @q.result.count.positive?
    @options_for_select = ProductSubCategory.all
    @options_for_select_cat = ProductCategory.all
    @product_sub_categories = @q.result(distinct: true).page(params[:page])
    download_product_sub_categories_csv_file if params[:csv].present?
    download_product_sub_categories_pdf_file if params[:pdf].present?
    send_email_file if params[:email].present?
    export_file if params[:export_data].present?
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
        notice_text = 'Product Sub category was successfully created.'
        notice_text = 'Unit Sub category was successfully created.' if pos_setting_sys_type.eql? 'HousingScheme'
        format.html { redirect_to product_sub_categories_path, notice: notice_text }
        format.json { render :show, status: :created, location: @product_sub_category }
      else
        format.html { redirect_to product_sub_categories_path, alert: 'Title is already present!' }
      end
    end
  end

  # PATCH/PUT /product_sub_categories/1
  # PATCH/PUT /product_sub_categories/1.json
  def update
    respond_to do |format|
      if @product_sub_category.update(product_sub_category_params)
        notice_text = 'Product Sub category was successfully updated.'
        notice_text = 'Unit Sub category was successfully updated.' if pos_setting_sys_type.eql? 'HousingScheme'
        format.html { redirect_to product_sub_categories_path, notice: notice_text }
        format.json { render :show, status: :ok, location: @product_sub_category }
      else
        format.html { redirect_to product_sub_categories_path, alert: 'Title is already present!' }
      end
    end
  end

  # DELETE /product_sub_categories/1
  # DELETE /product_sub_categories/1.json
  def destroy
    @product_sub_category.destroy
    respond_to do |format|
      notice_text = 'Product Sub category was successfully Deleted.'
      notice_text = 'Unit Sub category was successfully Deleted.' if pos_setting_sys_type.eql? 'HousingScheme'
      format.html { redirect_to product_sub_categories_path, notice: notice_text }
      format.json { render :show, status: :ok, location: @product_sub_category }
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

  def download_product_sub_categories_csv_file
    @product_sub_categories = @q.result
    header_for_csv = %w[Id Title Comment]
    data_for_csv = get_data_for_product_sub_categories_csv
    generate_csv(data_for_csv, header_for_csv, "ProductSubCategories-Total-#{@product_sub_categories.count}-#{DateTime.now.strftime("%d-%m-%Y-%H-%M")}")
  end

  def download_product_sub_categories_pdf_file
    @product_sub_categories = @q.result
    generate_pdf(@product_sub_categories.as_json, "ProductSubCategories-Total-#{@product_sub_categories.count}-#{DateTime.now.strftime("%d-%m-%Y-%H-%M")}", 'pdf.html', 'A4', false)
  end

  def send_email_file
    EmailJob.perform_later(@q.result.as_json, 'product_sub_categories/index.pdf.erb', params[:email_value],
                            params[:email_choice], params[:subject], params[:body],
                            current_user, "ProductSubCategories-Total-#{@q.result.count}-#{DateTime.now.strftime("%d-%m-%Y-%H-%M")}")
    if params[:email_value].present?
      flash[:notice] = "Email has been sent to #{params[:email_value]}"
    else
      flash[:notice] = "Email has been sent to #{current_user.email}"
    end
    redirect_to product_sub_categories_path
  end

  def export_file
    export_data('ProductSubCategory')
  end

end
