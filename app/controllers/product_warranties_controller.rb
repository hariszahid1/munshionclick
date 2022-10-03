class ProductWarrantiesController < ApplicationController
  before_action :set_product_warranty, only: [:show, :edit, :update, :destroy]

  # GET /product_warranties
  # GET /product_warranties.json
  def index
    @created_at_gteq = DateTime.now-365
    @created_at_lteq = DateTime.now
    @item_types = ItemType.all
    if params[:q].present?
      # @department = params[:q][:department_id]
      @created_at_gteq = params[:q][:created_at_gteq] if params[:q][:created_at_gteq].present?
      @created_at_lteq = params[:q][:created_at_lteq] if params[:q][:created_at_lteq].present?
      params[:q][:created_at_lteq] = params[:q][:created_at_lteq].to_date.end_of_day if params[:q][:created_at_lteq].present?
      @title = params[:q][:sys_user_id_eq]
      @code = params[:q][:credit_eq]
      @q = ProductWarranty.ransack(params[:q])
    else
      @q = ProductWarranty.where(created_at: @created_at_gteq.to_date.beginning_of_day..@created_at_lteq.to_date.end_of_day).ransack()
    end

    if @q.result.count > 0
      @q.sorts = 'id desc' if @q.sorts.empty?
    end
    @product_warranties_list = ProductWarranty.where(created_at: @created_at_gteq.to_date.beginning_of_day..@created_at_lteq.to_date.end_of_day)
    @products=Product.all
    @sys_user=SysUser.all
    @list_warranties=[]
    @product_warranties_list.pluck(:serial).uniq.each do |purchase|
      if purchase.present?
        purchase.split("\r\n").each do |purch|
          @list_warranties << purch
        end
      end
    end


    @product_warranties = @q.result.page(params[:page])
    @warranties_sale=@q.result.includes(:product).joins(:purchase_sale_detail).where('purchase_sale_details.transaction_type':'Sale')
    @warranties_purchase=@q.result.includes(:product).joins(:purchase_sale_detail).where('purchase_sale_details.transaction_type':'Purchase')
    @sale_count=0
    @purchase_count=0
    @sale_array=[]
    @purchase_array=[]
    @warranties_sale.pluck(:serial).compact.uniq.map(&:upcase).each do |purchase|
      purchase.upcase.split("\r\n").each do |purch|
        if params[:q].present? and params[:q][:serial_i_cont_any].compact.uniq.map(&:upcase).include? purch
          @sale_array << "<span class='gray'>"+purch+"</span>"
        else
          @sale_array << purch
        end
      end
      @sale_count=@sale_count+purchase.split("\r\n").count
    end
    @warranties_purchase.pluck(:serial).compact.uniq.map(&:upcase).each do |purchase|
      purchase.upcase.split("\r\n").each do |purch|
        if params[:q].present? and params[:q][:serial_i_cont_any].compact.uniq.map(&:upcase).include? purch
          @purchase_array << "<span class='gray'>"+purch+"</span>"
        else
          @purchase_array << purch
        end
      end
      @purchase_count=@purchase_count+purchase.split("\r\n").count
    end
    if params[:submit_pdf].present?
      if @q.result.count > 0
        @q.sorts = 'id desc' if @q.sorts.empty?
      end
      @product_warranties=@q.result
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
    elsif params[:submit_pdf_customer].present?
      if @q.result.count > 0
        @q.sorts = 'id desc' if @q.sorts.empty?
      end
      @product_warranties=@q.result
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

  # GET /product_warranties/1
  # GET /product_warranties/1.json
  def show
  end

  # GET /product_warranties/new
  def new
    @product_warranty = ProductWarranty.new
    @purchase_sale_detail=PurchaseSaleDetail.where(transaction_type:"Purchase").last(10)
    @product=Product.all
  end

  # GET /product_warranties/1/edit
  def edit
    @purchase_sale_detail=PurchaseSaleDetail.all
    @product=Product.all
  end

  # POST /product_warranties
  # POST /product_warranties.json
  def create
    @product_warranty = ProductWarranty.new(product_warranty_params)

    respond_to do |format|
      if @product_warranty.save
        format.html { redirect_to product_warranties_path, notice: 'Product warranty was successfully created.' }
        format.json { render :show, status: :created, location: @product_warranty }
      else
        format.html { render :new }
        format.json { render json: @product_warranty.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /product_warranties/1
  # PATCH/PUT /product_warranties/1.json
  def update
    respond_to do |format|
      if @product_warranty.update(product_warranty_params)
        format.html { redirect_to @product_warranty, notice: 'Product warranty was successfully updated.' }
        format.json { render :show, status: :ok, location: @product_warranty }
      else
        @purchase_sale_detail=PurchaseSaleDetail.all
        @product=Product.all
        format.html { render :edit }
        format.json { render json: @product_warranty.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /product_warranties/1
  # DELETE /product_warranties/1.json
  def destroy
    @product_warranty.destroy
    respond_to do |format|
      format.html { redirect_to product_warranties_url, notice: 'Product warranty was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
      def set_product_warranty
      @product_warranty = ProductWarranty.find(params[:id])
    end

    # Only allow a list of trusted parameters through.
    def product_warranty_params
      params.require(:product_warranty).permit(:purchase_sale_detail_id, :product_id, :serial)
    end
end
