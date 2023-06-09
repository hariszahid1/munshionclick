class ItemTypesController < ApplicationController
  include PdfCsvGeneralMethod
  include ItemTypesHelper
  before_action :check_access
  before_action :set_item_type, only: %i[show edit update destroy get_item_type_products]

  # GET /item_types
  # GET /item_types.json
  def index
    @q = ItemType.ransack(params[:q])
    @q.sorts = 'id asc' if @q.sorts.empty? && @q.result.count.positive?
    @options_for_select = ItemType.all
    @custom_pagination = params[:limit].present? ? params[:limit] : 25
    @custom_pagination = @pos_setting.custom_pagination['item_types'] if @pos_setting&.custom_pagination.present? && @pos_setting&.custom_pagination['item_types'].present?
    @item_types = @q.result.page(params[:page]).per(@custom_pagination)
    download_item_types_csv_file if params[:csv].present?
    download_item_types_pdf_file if params[:pdf].present?
    send_email_file if params[:email].present?
    export_file if params[:export_data].present?
  end

  # GET /item_types/1
  # GET /item_types/1.json
  def show
    respond_to do |format|
      format.js
    end
  end

  def get_item_type_products
    @products = @item_type.products
    respond_to do |format|
      format.js
    end
  end

  # GET /item_types/new
  def new
    @item_type = ItemType.new
    respond_to do |format|
      format.js
    end
  end

  # GET /item_types/1/edit
  def edit; end

  # POST /item_types
  # POST /item_types.json
  def create
    @item_type = ItemType.new(item_type_params)

    respond_to do |format|
      if @item_type.save
        format.js
        format.html { redirect_to item_types_url, notice: 'Item type was successfully created.' }
        format.json { render :show, status: :created, location: @item_type }
      else
        format.html { redirect_to item_types_path, alert: 'Title is already present!' }
      end
    end
  end

  # PATCH/PUT /item_types/1
  # PATCH/PUT /item_types/1.json
  def update
    respond_to do |format|
      if @item_type.update(item_type_params)
        format.html { redirect_to item_types_url, notice: 'Item type was successfully updated.' }
        format.json { render :show, status: :ok, location: @item_type }
      else
        format.html { redirect_to item_types_path, alert: 'Title is already present!' }
      end
    end
  end

  # DELETE /item_types/1
  # DELETE /item_types/1.json
  def destroy
    @item_type.destroy
    respond_to do |format|
      format.html { redirect_to item_types_path, notice: 'Item type was successfully Deleted.' }
      format.json { render :show, status: :ok, location: @item_type }
    end
  end

  private

  # Use callbacks to share common setup or constraints between actions.
  def set_item_type
    @item_type = ItemType.find(params[:id])
  end

  # Never trust parameters from the scary internet, only allow the white list through.
  def item_type_params
    params.require(:item_type).permit(:title, :code, :comment)
  end

  def download_item_types_csv_file
    @item_type = @q.result
    header_for_csv = %w[Id Title Code Comment]
    data_for_csv = get_data_for_item_types_csv
    generate_csv(data_for_csv, header_for_csv,
                 "ItemTypes-Total-#{@item_type.count}-#{DateTime.now.strftime('%d-%m-%Y-%H-%M')}")
  end

  def download_item_types_pdf_file
    @item_type = @q.result
    generate_pdf(@item_type.as_json, "ItemTypes-Total-#{@item_type.count}-#{DateTime.now.strftime('%d-%m-%Y-%H-%M')}",
                 'pdf.html', 'A4', false, 'item_types/index.pdf.erb')
  end

  def send_email_file
    EmailJob.perform_later(@q.result.as_json, 'item_types/index.pdf.erb', params[:email_value],
                           params[:email_choice], params[:subject], params[:body],
                           current_user, "ItemTypes-Total-#{@q.result.count}-#{DateTime.now.strftime('%d-%m-%Y-%H-%M')}")
    flash[:notice] = if params[:email_value].present?
                       "Email has been sent to #{params[:email_value]}"
                     else
                       "Email has been sent to #{current_user.email}"
                     end
    redirect_to item_types_path
  end

  def export_file
    export_data('ItemType')
  end
end
