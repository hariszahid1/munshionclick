class ProductsController < ApplicationController
  include PdfCsvGeneralMethod
  before_action :check_access
  before_action :set_product, only: [:show, :edit, :update, :destroy]
  skip_before_action :authenticate_user!, only: [:index]
  include CsvMethods
  # GET /products
  # GET /products.json
  def index
    @q = Product.ransack(params[:q])
    @status = ''
    if params[:q].present?
      @status = params[:q][:size_6_in]
      params[:q][:size_6_in] = nil
      @code = params[:q][:code_cont_any]
      @item_type = params[:q][:item_type_title_cont_any]
      @product_category = params[:q][:product_category_title_cont_any]
      @product_sub_category = params[:q][:product_sub_category_title_cont_any]
      @q = Product.booked_plot.ransack(params[:q]) if @status == '0'
      @q = Product.open_plot.ransack(params[:q]) if @status == '1'
      @q = Product.secure_plot.ransack(params[:q]) if @status == '2'
      only_booked_plot = Product.only_booked_plot if @status == '3'
      @q = Product.where(id: only_booked_plot).ransack(params[:q]) if @status == '3'
      params[:q][:size_6_in] = @status
    end
    @q.sorts = 'id desc' if @q.result.count.positive? && @q.sorts.empty?
    @product = Product.pluck(:id, :title, :code)
    @product_categories = ProductCategory.pluck(:id, :title, :code)
    @product_sub_categories = ProductSubCategory.pluck(:id, :title, :code)

    # @item_types = ItemType.all
    @item_types = ItemType.pluck(:id, :title, :code)
    p_ids = []
    if [params[:commission_in_per], params[:paid_in_per], params[:phone_number_in], params[:last_payment], params[:paid_in_per_less]].any?(&:present?)
      @q.result.each do |product|
        staff_deal_orders = product.orders
        next if staff_deal_orders.blank?

        token = staff_deal_orders.last&.purchase_sale_details&.first
        phone_no = staff_deal_orders.last&.sys_user&.contact&.phone_with_comma
        last_pay = staff_deal_orders.last&.sys_user&.ledger_books&.last&.created_at
        sys = staff_deal_orders.last&.sys_user&.ledger_books&.pluck('SUM(debit)', 'SUM(credit)')&.first
        sys_first = sys&.first.to_f
        sys_second = sys&.second.to_f
        paid_in_per = ((sys_second / sys_first) * 100).round(2).to_s
        commission_in_per = ((token&.carriage.to_f / sys_first) * 100).round(2).to_s
        next if params[:commission_in_per].present? && commission_in_per.to_f < params[:commission_in_per].to_f
        next if params[:paid_in_per].present? && paid_in_per.to_f <= params[:paid_in_per].to_f
        next if params[:paid_in_per_less].present? && paid_in_per.to_f >= params[:paid_in_per_less].to_f
        next if params[:phone_number_in].present? && phone_no.to_s.exclude?(params[:phone_number_in])
        next if params[:last_payment].present? && last_pay.present? && last_pay.to_date < params[:last_payment].to_date

        p_ids.push(product.id)
      end
      @q = @q.result.where(id: p_ids).ransack(params[:q])
    end
    if params.dig(:q, :size_6_in) == '1'
      product_ids = OrderItem.joins(:order).where(orders: { status: %w[Clear Order UnClear UnPrint Printed] })
                             .select(:product_id).distinct.pluck(:product_id)
      params[:q][:size_6_in] = nil
      @q = Product.where.not(id: product_ids).ransack(params[:q])
      @products = @q.result.page(params[:page]).per(100)
      export_file if params[:export_data].present?
      @products_total_price = @q.result.map { |result| result[:sale].to_f*(result[:marla].to_f + result[:square_feet].to_f / 225.0) }.sum
      @products_total_marla = @q.result.sum(:marla)
      @products_total_sq_ft = @q.result.sum(:square_feet)
      params[:q][:size_6_in] = 1
    else
      @products = @q.result.page(params[:page]).per(100)
      export_file if params[:export_data].present?
      @products_total_price = @q.result.map { |result| result[:sale].to_f*(result[:marla].to_f + result[:square_feet].to_f / 225.0) }.sum
      @products_total_marla = @q.result.sum(:marla)
      @products_total_sq_ft = @q.result.sum(:square_feet)
    end

    if params[:submit_pdf_staff_with].present? || params[:submit_pdf_staff].present?
      @q.sorts = 'item_type_title desc' if @q.result.count.positive? && @q.sorts.empty?
      @products = @q.result
      print_pdf('products', 'pdf.html', 'A4')
    end

    @pos_setting = PosSetting.first

    if params[:submit_pdf_staff_barcode].present?
      require 'barby'
      require 'barby/barcode/code_128'
      require 'barby/outputter/svg_outputter'
      @str = []
      @products.each do |product|
        code = product.code.to_s
        name = product.title.to_s
        @svg = Barby::Code128B.new(code).to_svg
        File.open("public/barcode#{code}.svg'", 'wb') { |f| f.write @svg }
        files_content = File.read("public/barcode#{code}.svg'")
        @str << [code, name, Base64.encode64(files_content).gsub("\n", '')]
      end
      @q.sorts = 'item_type_title desc' if @q.result.count.positive? && @q.sorts.empty?
      @products = @q.result
      print_pdf('index_bar', 'index_bar.pdf', 'A4')
    end
    
    product_charts
    
    return unless params[:csv_staff].present? || params[:csv_staff_with].present?
    @products = @q.result
    csv_data = products_csv
    request.format = 'csv'
    respond_to do |format|
      format.html
      format.csv { send_data csv_data, filename: "Unit/Inventory Detail - #{Date.today}.csv" }
    end
  end

  # GET /products/1
  # GET /products/1.json
  def show
    if params[:barcode].present?
      code=@product.code.to_s
      require 'barby'
      require 'barby/barcode/code_128'
      require 'barby/outputter/svg_outputter'
      @svg= Barby::Code128B.new(code).to_svg
      File.open('public/barcode.svg', 'wb'){|f| f.write @svg }
      files_content = File.read("public/barcode.svg")
      @str=Base64.encode64(files_content ).gsub("\n", '')
      # pdf_filename = File.join(Rails.root, "tmp/barcode.svg")
      # send_file(pdf_filename, :filename => "barcode.svg", :type => "application/svg")
      print_barcode('BarCode')

      #Convenience method
      # File.open('barcode2.png', 'wb'){|f| f.write barcode.to_png }
      # barcode = Barcodes.create('Code 128', {:data => code})
      # pdf_renderer = Barcodes::Renderer::Pdf.new(barcode)
      # pdf_renderer.render('tmp/output.pdf')
      # pdf_filename = File.join(Rails.root, "tmp/output.pdf")
      # send_file(pdf_filename, :filename => "output.pdf", :type => "application/pdf")
    end

    require "rqrcode"

    qrcode = RQRCode::QRCode.new("http://lahoremodrencity.com/")

    # NOTE: showing with default options specified explicitly
    @svg = qrcode.as_svg(
      color: "000",
      shape_rendering: "crispEdges",
      module_size: 11,
      standalone: true,
      use_path: true
    )
    File.open('public/barcode.svg', 'wb'){|f| f.write @svg }
    files_content = File.read("public/barcode.svg")
    @str=Base64.encode64(files_content ).gsub("\n", '')
  end

  # GET /products/new
  def new
    @product = Product.new
    @product_categories=ProductCategory.all
    @product_sub_categories=ProductSubCategory.all
    @raw_products = RawProduct.all
    @item_types=ItemType.all
  end

  # GET /products/1/edit
  def edit
    @product_categories=ProductCategory.all
    @product_sub_categories=ProductSubCategory.all
    @item_types=ItemType.all
    @raw_products = RawProduct.all

  end

  # POST /products
  # POST /products.json
  def create
    @product = Product.new(product_params)
    if current_user.superAdmin.company_type=="batamega"
      @product.stock=@product.size_1.to_i+@product.size_2.to_i+@product.size_3.to_i+@product.size_4.to_i+@product.size_5.to_i+@product.size_6.to_i+@product.size_7.to_i+@product.size_8.to_i+@product.size_9.to_i+@product.size_10.to_i+@product.size_11.to_i+@product.size_12.to_i+@product.size_13.to_i
    end
    respond_to do |format|
      if @product.save
        format.js
        format.html { redirect_to products_url, notice: 'Product was successfully created.' }
        format.json { render :show, status: :created, location: @product }
      else
        @product_categories=ProductCategory.all
        @product_sub_categories=ProductSubCategory.all
        @raw_products = RawProduct.all
        @item_types=ItemType.all
        format.html { render :new }
        format.json { render json: @product.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /products/1
  # PATCH/PUT /products/1.json
  def update
    respond_to do |format|
      if @product.update(product_params)
        if current_user.superAdmin.company_type=="batamega"
          @product.stock=@product.size_1.to_i+@product.size_2.to_i+@product.size_3.to_i+@product.size_4.to_i+@product.size_5.to_i+@product.size_6.to_i+@product.size_7.to_i+@product.size_8.to_i+@product.size_9.to_i+@product.size_10.to_i+@product.size_11.to_i+@product.size_12.to_i+@product.size_13.to_i
          @product.save!
        end
        format.html { redirect_to products_url, notice: 'Product was successfully updated.' }
        format.json { render :show, status: :ok, location: @product }
      else
        @product_categories=ProductCategory.all
        @product_sub_categories=ProductSubCategory.all
        @raw_products = RawProduct.all
        @item_types=ItemType.all
        format.html { render :edit }
        format.json { render json: @product.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /products/1
  # DELETE /products/1.json
  def destroy
    @product.destroy
    respond_to do |format|
      format.html { redirect_to products_url, notice: 'Product was successfully destroyed.' }
      format.json { head :no_content }
      format.js   { render :layout => false }
    end
  end

  def get_product_data
    product_warranty_list = Product.pluck(:warranty_list).reject(&:blank?).join("\r\n")
    if params[:order_id].present?
      order = Order.find_by(id: params[:order_id])
      order_item = order.order_items.find_by_product_id(params[:product_id])
      if order_item.present?
        product = Product.find_by(id: params[:product_id])
        gst = (product.gst.present? && !product.gst.zero?) ? product.gst : product.vat
        respond_to do |format|
          format.json { render json: {status: 'success', cost: order_item.cost_price.to_f, sale: order_item.sale_price, stock: product.stock, serial: product.with_serial, warranty_list: product_warranty_list,size_1: product.size_1, size_2: product.size_2, size_3: product.size_3, size_4: product.size_4, size_5: product.size_5, size_6: product.size_6, size_7: product.size_7, size_8: product.size_8, size_9: product.size_9, size_10: product.size_10, size_11: product.size_11, size_12: product.size_12, size_13: product.size_13, gst: gst, sys_type: pos_setting_sys_type}, status: :ok}
        end
      else
        product = Product.find_by(id: params[:product_id])
        gst = (product.gst.present? && !product.gst.zero?) ? product.gst : product.vat
        respond_to do |format|
          format.json { render json: {status: 'success', cost: product.cost, sale: product.sale, stock: product.stock, serial: product.with_serial, warranty_list: product_warranty_list, size_1: product.size_1, size_2: product.size_2, size_3: product.size_3, size_4: product.size_4, size_5: product.size_5, size_6: product.size_6, size_7: product.size_7, size_8: product.size_8, size_9: product.size_9, size_10: product.size_10, size_11: product.size_11, size_12: product.size_12, size_13: product.size_13, gst: gst, sys_type: pos_setting_sys_type}, status: :ok}
        end
      end
    elsif params[:purchase_id].present?
      purchase = PurchaseSaleDetail.find_by(id: params[:purchase_id])
      purchase_item = purchase.purchase_sale_items.find_by_product_id(params[:product_id])
      if purchase_item.present?
        product = Product.find_by(id: params[:product_id])
        gst = (product.gst.present? && !product.gst.zero?) ? product.gst : product.vat
        respond_to do |format|
          format.json { render json: {status: 'success', cost: purchase_item.cost_price.to_f, sale: purchase_item.sale_price, stock: product.stock, serial: product.with_serial, warranty_list: product_warranty_list,size_1: product.size_1, size_2: product.size_2, size_3: product.size_3, size_4: product.size_4, size_5: product.size_5, size_6: product.size_6, size_7: product.size_7, size_8: product.size_8, size_9: product.size_9, size_10: product.size_10, size_11: product.size_11, size_12: product.size_12, size_13: product.size_13, gst: gst, sys_type: pos_setting_sys_type}, status: :ok}
        end
      else
        product = Product.find_by(id: params[:product_id])
        gst = (product.gst.present? && !product.gst.zero?) ? product.gst : product.vat
        respond_to do |format|
          format.json { render json: {status: 'success', cost: product.cost, sale: product.sale, stock: product.stock, serial: product.with_serial, warranty_list: product_warranty_list, size_1: product.size_1, size_2: product.size_2, size_3: product.size_3, size_4: product.size_4, size_5: product.size_5, size_6: product.size_6, size_7: product.size_7, size_8: product.size_8, size_9: product.size_9, size_10: product.size_10, size_11: product.size_11, size_12: product.size_12, size_13: product.size_13, gst: gst, sys_type: pos_setting_sys_type}, status: :ok}
        end
      end
    else
      product = Product.find_by(id: params[:product_id])
      product_warranty_list = product.warranty_list if params[:transaction_type]=="sale"
      gst = (product.gst.present? && !product.gst.zero?) ? product.gst : product.vat
      respond_to do |format|
        format.json { render json: {status: 'success', cost: product.cost, sale: product.sale, stock: product.stock, serial: product.with_serial, warranty_list: product_warranty_list, size_1: product.size_1, size_2: product.size_2, size_3: product.size_3, size_4: product.size_4, size_5: product.size_5, size_6: product.size_6, size_7: product.size_7, size_8: product.size_8, size_9: product.size_9, size_10: product.size_10, size_11: product.size_11, size_12: product.size_12, size_13: product.size_13, gst: gst, marla: product.marla, square_feet: product.square_feet, sys_type: pos_setting_sys_type}, status: :ok}
      end
    end
  end

  def view_history
    @start_date = Date.today.beginning_of_month
    @end_date =  Date.today.end_of_month
    if params[:q].present?
      @start_date = params[:q][:created_at_gteq] if params[:q][:created_at_gteq].present?
      @end_date = params[:q][:created_at_lteq] if params[:q][:created_at_lteq].present?
      @item_id = params[:q][:item_id_eq] if params[:q][:item_id_eq].present?
      params[:q][:created_at_lteq] = params[:q][:created_at_lteq].to_date.end_of_day if params[:q][:created_at_lteq].present?
    end
    @event = %w[create update destroy]
    @q = PaperTrail::Version.where(item_type:"Product").order('created_at desc').ransack(params[:q])
    @product_logs = @q.result.page(params[:page])
    @product_sub_categories = ProductSubCategory.all.pluck(:id, :title).to_h
    @item_types = ItemType.all.pluck(:id, :title).to_h
    @product_categories = ProductCategory.all.pluck(:id, :title).to_h
    respond_to do |format|
      format.js
    end
  end

  def bulk_update_price
    product_ids = OrderItem.joins(:order).where(orders: { status: %w[Clear Order UnClear UnPrint Printed] })
                           .select(:product_id).distinct.pluck(:product_id)
    @products = Product.where.not(id: product_ids)
                       .where(product_category_id: params[:bulk_update][:product_category_id],
                              product_sub_category_id: params[:bulk_update][:product_sub_category_id],
                              item_type_id: params[:bulk_update][:item_type_id])
    miniumum_sale = @products.minimum(:sale)
    if miniumum_sale.to_f < params[:bulk_update][:sale].to_f || current_user.super_admin?
      @products.update_all(sale: params[:bulk_update][:sale])
      flash[:notice] = 'Sale rates are updated successfully.'
    else
      flash[:alert] = "You can't set the price less than #{miniumum_sale}"
    end
    redirect_to products_url
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_product
      @product = Product.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def product_params
      params.require(:product).permit(
        :item_type_id,
        :code, :title,
        :product_category_id,
        :product_sub_category_id,
        :acquire_type,
        :purchase_type,
        :product_type,
        :purchase_unit,
        :purchase_factor,
        :cost,
        :sale,
        :minimum,
        :optimal,
        :maximum,
        :currency,
        :stock,
        :size_1,
        :size_2,
        :size_3,
        :size_4,
        :size_5,
        :size_6,
        :size_7,
        :size_8,
        :size_9,
        :size_10,
        :size_11,
        :size_12,
        :size_13,
        :raw_product_id,
        :gst, :vat,
        :hst,
        :pst,
        :qst,
        :with_serial,
        :warranty_list,
        :marla,
        :square_feet,
        :profile_image,
        :quantity_type,
        :weight_type,
        :links_attributes => [
          :id,
          :qrcode,
          :brcode,
          :herf,
          :title,
          :_destroy
        ]
      )
    end

    def product_charts
      @block_item = Product.joins(:item_type).group('item_types.title').sum(:sale)
      @block_keys = @block_item.keys.map { |a| a.gsub(' ', '-') }
      @block_count = @block_item.values

      @block_occurence = Product.joins(:item_type).group('item_types.title').count
      @b_title = @block_occurence.keys.map { |a| a.gsub(' ', '-') }
      @b_count = @block_occurence.values

      @category_revenue = Product.joins(:product_category).group('product_categories.title').sum(:sale)
      @cat_keys = @category_revenue.keys.map { |a| a.gsub(' ', '-') }
      @cat_sum = @category_revenue.values

      @sub_category_revenue = Product.joins(:product_sub_category).group('product_sub_categories.title').sum(:sale)
      @sub_cat_keys = @sub_category_revenue.keys.map { |a| a.gsub(' ', '-') }
      @sub_cat_sum = @sub_category_revenue.values

    end

    def export_file
      export_data('Product')
    end
end

