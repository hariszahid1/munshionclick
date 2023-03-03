class OrderOutwardsController < ApplicationController
  include PdfCsvGeneralMethod
  include OutwardsHelper

  before_action :set_order, only: %i[show edit update destroy]
  skip_before_action :authenticate_user!, only: [:show]
  before_action :new_edit_index_data, only: %i[edit new index create]
  require 'tempfile'
  require 'csv'

  # GET /order_inwards
  # GET /order_inwards.json
  def index
    date_search
    @q = Order.includes(:sys_user, order_items: :product).where(transaction_type: 'Outward').ransack(params[:q])
    @orders = @q.result.distinct.order('orders.created_at desc').page(params[:page])
    @pdf_orders = @q.result
    if params[:pdf].present?
      @pdf_orders_total = @pdf_orders.sum('order_items.comment')
      @pdf_outward_total = @pdf_orders.group('sys_users.name').sum('order_items.comment')
      download_outwards_pdf_file
    end
  end

  # GET /order_inwards/1
  # GET /order_inwards/1.json
  def show
    download_show_pdf_file if params[:pdf].present?
  end

  # GET /orders/new
  def new
    @order = Order.new
    @order.order_items.build
    @account = current_user.user_account
  end

  # GET /order_inwards/1/edit
  def edit
    sys_user_id = @order.sys_user_id
    product_ids = PurchaseSaleItem.joins(:purchase_sale_detail).where('purchase_sale_details.sys_user_id': sys_user_id, 'purchase_sale_details.transaction_type': "InWard").pluck(:product_id).uniq
    @products = Product.where(id: product_ids)
    @markas = PurchaseSaleItem.where('product_id': product_ids, 'transaction_type': "Purchase").pluck(:size_13).uniq
    @challans = PurchaseSaleItem.where('size_13': @markas, 'transaction_type': "Purchase").pluck(:size_10).uniq
  end

  # POST /order_inwardss
  # POST /order_inwards.json
  def create
    @order = Order.new(order_params)
    @pos_setting = PosSetting.first
    ledgerbook = LedgerBook.where(sys_user_id: order_params[:sys_user_id]).present? ? LedgerBook.where(sys_user_id: order_params[:sys_user_id]).last.balance : 0
    balance = ledgerbook
    @sysuser= SysUser.find(order_params[:sys_user_id]).present? ? SysUser.find(order_params[:sys_user_id]) : SysUser.first
    if balance.zero?
      sysuser = @sysuser.present? ? @sysuser.opening_balance : 0
      balance = sysuser
    end
    fullbalance = order_params[:amount].to_i+(balance.to_i)
    @time = Time.zone.now
    Order.maximum(:id).present? ? psd = Order.maximum(:id).next : psd=1
    @id = Order.where(created_at: Time.zone.now.beginning_of_day..Time.zone.now.end_of_day).count + 1
    @order.voucher_id = @id

    respond_to do |format|
      if @order.save
        PaymentBalanceJob.set(wait: 1.minutes).perform_later(current_user.superAdmin.company_type)
        @ledger_book = LedgerBook.new(sys_user_id: @sysuser.id, debit: 0, credit: order_params[:amount].to_i, balance: fullbalance,comment:"Booking #"+psd.to_s+"  ||  "+(order_params["created_at(3i)"])+"/"+(order_params["created_at(2i)"])+"/"+(order_params["created_at(1i)"])+" "+@time.strftime("at %I:%M%p"),order_id: @order.id,account_id: @order.account_id)
        @ledger_book.save!
        format.html { redirect_to order_outwards_path, notice: 'Outward Order was successfully created.' }
        format.json { render :show, status: :created, location: @order }
      else
        format.html { render :new }
        format.json { render json: @order.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /orders/1
  # PATCH/PUT /orders/1.json
  def update
    @pos_setting = PosSetting.first
    respond_to do |format|
      if @order.update(order_params)
        UserLedgerBookJob.perform_later(current_user.superAdmin.company_type, @order.sys_user_id)
        AccountPaymentJob.perform_later(current_user.superAdmin.company_type, @order.account_id)
        format.html { redirect_to order_outwards_path, notice: 'Outward order detail was successfully updated.' }
        format.json { render :show, status: :ok, location: @order }
      else
        format.html { render :edit }
        format.json { render json: @order.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /orders/1
  # DELETE /orders/1.json
  def destroy
    @order.destroy
    UserLedgerBookJob.perform_later(current_user.superAdmin.company_type,@order.sys_user_id)
    AccountPaymentJob.perform_later(current_user.superAdmin.company_type,@order.account_id)
    respond_to do |format|
      format.html { redirect_to orders_outwards_path, notice: 'Outward Order detail was successfully destroyed.' }
      format.json { head :no_content }
      format.js   { render layout: false }
    end
  end

  def get_outward_party_data
    sys_user_id = params[:id]
    product_ids = PurchaseSaleItem.joins(:purchase_sale_detail).where('purchase_sale_details.sys_user_id': sys_user_id, 'purchase_sale_details.transaction_type': "InWard").pluck(:product_id).uniq
    products = Product.where(id: product_ids)
    respond_to do |format|
      format.json { render json: products }
    end
  end

  def get_outward_marka_data
    product_id = params[:product_id]
    sys_user_id = params[:party_id]
    markas = PurchaseSaleItem.joins(:purchase_sale_detail).where('purchase_sale_details.sys_user_id': sys_user_id, 'purchase_sale_details.transaction_type': "InWard", 'product_id': product_id).pluck(:size_13).uniq
    respond_to do |format|
      format.json { render json: markas }
    end
  end

  def get_outward_challan_data
    marka = params[:marka_id]
    product_id = params[:product_id]
    sys_user_id = params[:party_id]
    p_item = PurchaseSaleItem.joins(:purchase_sale_detail).where('purchase_sale_details.sys_user_id': sys_user_id, 'purchase_sale_details.transaction_type': "InWard", 'product_id': product_id,'size_13': marka)
    challan_no = p_item.map{ |item| [item.size_10, "(#{item.purchase_sale_detail.created_at.to_date})"] }.uniq
    respond_to do |format|
      format.json { render json: challan_no }
    end
  end

  def get_outward_stock_data
    sys_user_id = params[:party_id]
    marka_no = params[:marka_no]
    challan_no = params[:challan_no]
    product_id = params[:product_id]

    out_stock = PurchaseSaleItem.joins(:purchase_sale_detail).where('purchase_sale_details.sys_user_id': sys_user_id, 'purchase_sale_details.transaction_type': "OutWard", 'product_id': product_id, 'size_13': marka_no, 'size_10': challan_no).sum(:size_9)
    in_stock = PurchaseSaleItem.joins(:purchase_sale_detail).where('purchase_sale_details.sys_user_id': sys_user_id, 'purchase_sale_details.transaction_type': "InWard", 'product_id': product_id, 'size_13': marka_no, 'size_10': challan_no).sum(:size_9)
    stock = in_stock.to_f-out_stock.to_f

    respond_to do |format|
      format.json { render json: stock }
    end
  end

  private

  # Use callbacks to share common setup or constraints between actions.
  def set_order
    @order = Order.find(params[:id])
  end

   # Only allow a list of trusted parameters through.
  def order_params
    params.require(:order).permit(
      :sys_user_id,
      :transaction_type,
      :total_bill,
      :amount,
      :discount_price,
      :status,
      :comment,
      :voucher_id,
      :account_id,
      :carriage,
      :loading,
      :with_gst,
      :created_at,
      :payment_method,
      :bank_detail,
      order_images: [],
      :remarks_attributes => [
        :id,
        :user,
        :body,
        :message,
        :comment,
        :remark_type,
        :remarkable_type,
        :remarkable_id
      ],
      :order_items_attributes => [
        :id,
        :gst,
        :gst_amount,
        :purchase_sale_detail_id,
        :item_id,
        :product_id,
        :quantity,
        :cost_price,
        :sale_price,
        :status,
        :comment,
        :total_cost_price,
        :total_sale_price,
        :transaction_type,
        :discount_price,
        :purchase_sale_type,
        :created_at,
        :expiry_date,
        :extra_expence,
        :marla,
        :square_feet,
        :_destroy,
        :marka,
        :builty_no,
        :vehicle_no,
        :challan_no
      ],
      :links_attributes => [
        :id,
        :qrcode,
        :brcode,
        :herf,
        :title,
        :_destroy
      ],
      :property_plans_attributes => [
        :id,
        :property_type,
        :area_in_marla,
        :price_per_marla,
        :total_price,
        :payment_type,
        :payment_plan,
        :no_of_installments,
        :advance,
        :high_amount_installments,
        :total_high_amount,
        :created_at,
        :updated_at,
        :order_id,
        :last_instalment,
        :due_date,
        :due_status,
        :payment_method,
        :bank_detail,
        :_destroy,
        :property_installments_attributes => [
          :id,
          :property_plan_id,
          :installment_no,
          :installment_price,
          :high_price,
          :normal_price,
          :created_at,
          :updated_at,
          :due_date,
          :due_status,
          :payment_method,
          :bank_detail,
          :_destroy
        ]
      ]
    )
  end

  def download_outwards_pdf_file
    @sys_users = @q.result
    sorted_data
    generate_pdf(@sorted_data.as_json, 'Outward', 'pdf.html', 'A4', false, 'order_outwards/index.pdf.erb')
  end


  def download_show_pdf_file
    sorted_show_data
    generate_pdf(@sorted_data.as_json, 'Inward', 'pdf.html', 'A4', false, 'order_outwards/show.pdf.erb')
  end

  def new_edit_index_data
    @products = Product.all
    @accounts = Account.all
    @suppliers = SysUser.all
    @item_types = ItemType.all
    @items = Item.all
  end

  def date_search
    @created_at_gteq = DateTime.current.beginning_of_month
    @created_at_lteq = DateTime.now
    if params[:q].present?
      @created_at_gteq = params[:q][:created_at_gteq] if params[:q][:created_at_gteq].present?
      @created_at_lteq = params[:q][:created_at_lteq] if params[:q][:created_at_lteq].present?
      params[:q][:created_at_lteq] = params[:q][:created_at_lteq].to_date.end_of_day if params[:q][:created_at_lteq].present?
    end
  end
end
