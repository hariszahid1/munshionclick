# frozen_string_literal: true

# FollowUps Controller
class ColdStorageInwardsController < ApplicationController
  include PdfCsvGeneralMethod
  include InwardsHelper

  before_action :set_cold_storage, only: %i[show edit update destroy]
  before_action :index_edit_new_data, only: %i[new show edit index]

  def index
    date_search
    index_data
    @q = PurchaseSaleDetail.includes(:order, :account, :sys_user,
                                     purchase_sale_items: :product).ransack(params[:q])
    purchase_sale_detail = @q.result.distinct.where(transaction_type: 'InWard')
    @purchase_sale_details = purchase_sale_detail.order('purchase_sale_details.created_at desc').page(params[:page]).per(100)
    @pdf_orders = @q.result
    @cold_storage_inward_total = purchase_sale_detail.group('purchase_sale_details.id').sum('purchase_sale_items.size_9')
    if params[:pdf].present?
      @pdf_orders_total = @pdf_orders.sum('purchase_sale_items.quantity')
      @pdf_inward_total = @pdf_orders.group('sys_users.name').sum('purchase_sale_items.quantity')
      download_cold_storage_inwards_pdf_file
    end
  end

  def new
    @purchase_sale_details = PurchaseSaleDetail.all
    @purchase_sale_detail = PurchaseSaleDetail.new(order_id: params[:order_id],
                                                   sys_user_id: params[:sys_user_id])
    if params[:order_id].present?
      order=Order.find(params[:order_id])
      order.order_items.each do |ord|
        @purchase_sale_detail.purchase_sale_items.build(product_id: ord.product_id, size_13: ord.marka, size_12: ord.builty_no, size_11: ord.vehicle_no, size_10: ord.challan_no, size_9: ord.quantity, quantity: ord.quantity)
      end
    end
    @staffs = Staff.joins(:department).where('departments.active': true)
  end

  def edit
    @staffs = Staff.joins(:department).where('departments.active': true)
  end

  def create
    PurchaseSaleDetail.maximum(:id).present? ? psd = PurchaseSaleDetail.maximum(:id).next : psd=1
    create_data
    balance = @sysuser.balance
    fullbalance = balance.to_f - purchase_sale_detail_params[:amount].to_f
    respond_to do |format|
      if @purchase_sale_detail.save!
        @ledger_book = LedgerBook.new(sys_user_id: @sysuser.id, debit: purchase_sale_detail_params[:amount].to_f,
          credit: 0.0, balance: fullbalance, comment: "Voucher #" + psd.to_s+"  ||  " +
          (purchase_sale_detail_params["created_at(3i)"])+"/" +(purchase_sale_detail_params["created_at(2i)"])+"/"+
          (purchase_sale_detail_params["created_at(1i)"])+" "+ @time.strftime("at %I:%M%p"),
          purchase_sale_detail_id: @purchase_sale_detail.id,account_id: @purchase_sale_detail.account_id)
        @ledger_book.save!
        if @purchase_sale_detail.staff_id.present?
          # @purchase_sale_detail.salary_detail_id=salary_detail.id
          staff = @purchase_sale_detail.staff
          staff.wage_debit += @purchase_sale_detail.carriage+@purchase_sale_detail.loading
          staff.balance += @purchase_sale_detail.carriage+@purchase_sale_detail.loading
          staff.save!
          @purchase_sale_detail.salary_details.create(staff_id: @purchase_sale_detail.staff_id, amount: @purchase_sale_detail.carriage, comment: "Carriage", total_balance: staff.balance-@purchase_sale_detail.loading,quantity: @purchase_sale_detail.purchase_sale_items_quantities, created_at: @purchase_sale_detail.created_at)
          @purchase_sale_detail.salary_details.create(staff_id: @purchase_sale_detail.staff_id, amount: @purchase_sale_detail.loading, comment: "Loading", total_balance: staff.balance,created_at: @purchase_sale_detail.created_at)
          # @purchase_sale_detail.save!
        end
        format.html { redirect_to order_inwards_path, notice: 'Cold Storage was successfully created.' }
        format.json { render :show, status: :created, location: @purchase_sale_detail }
      else
        format.html { render :new }
        format.json { render json: @purchase_sale_detail.errors, status: :unprocessable_entity }
      end
    end
  end

  def show
    download_inward_show_pdf_file if params[:pdf].present?
  end

  def update
    @pos_setting=PosSetting.first
    respond_to do |format|
      purchase = Hash.new
      @purchase_sale_detail.purchase_sale_items.each do |item|
        purchase[item.product_id]=item.quantity if item.product_id.present?
      end
      @before_products_cost = @purchase_sale_detail.purchase_sale_items.group(:product_id).sum(:cost_price)
      @before_products_quantity = @purchase_sale_detail.purchase_sale_items.group(:product_id).sum('purchase_sale_items.quantity')
      @before_products_count = @purchase_sale_detail.purchase_sale_items.group(:product_id).count
      if @purchase_sale_detail.update!(purchase_sale_detail_params)
        products = @purchase_sale_detail.purchase_sale_items.pluck(:product_id, 'purchase_sale_items.quantity', :cost_price)
        products.each do |product|
          if purchase[product.first].present?
            product_quantity = product.second.to_f-purchase[product.first].to_f
            productstock = Product.find(product.first)
            cost_price =(((productstock.cost.to_f)*(([productstock.stock.to_f, 0].max).to_f))-((@before_products_cost[product.first].to_f/@before_products_count[product.first].to_f)*@before_products_quantity[product.first].to_f)+(product.last.to_f*product.second.to_f))/([productstock.stock.to_f, 0].max.to_f+product.second.to_f-@before_products_quantity[product.first].to_f)
            if cost_price.present? && !cost_price.nan?
              productstock.update!(stock: productstock.stock.to_f+ product_quantity,cost: cost_price.to_f)
            else
              productstock.update!(stock: productstock.stock.to_f + product_quantity)
            end
          end
        end
        UserLedgerBookJob.perform_later(current_user.superAdmin.company_type, @purchase_sale_detail.sys_user_id)
        AccountPaymentJob.perform_later(current_user.superAdmin.company_type, @purchase_sale_detail.account_id)
        SalaryDetailJob.perform_later(current_user.superAdmin.company_type, @purchase_sale_detail.staff_id)
        format.html { redirect_to cold_storage_inwards_path, notice: 'Inward was successfully updated.' }
        format.json { render :show, status: :ok, location: @purchase_sale_detail }
      else
        format.html { render :edit }
        format.json { render json: @purchase_sale_detail.errors, status: :unprocessable_entity }
      end
    end
  end

  def destroy
    type = @purchase_sale_detail.transaction_type
    @products = Product.where(id:@purchase_sale_detail.purchase_sale_items.pluck(:product_id))
    @purchase_sale_detail.destroy
    ledger_book = @purchase_sale_detail.sys_user.ledger_books.last
    UserLedgerBookJob.perform_later(current_user.superAdmin.company_type,@purchase_sale_detail.sys_user_id)
    AccountPaymentJob.perform_later(current_user.superAdmin.company_type,@purchase_sale_detail.account_id)
    SalaryDetailJob.perform_later(current_user.superAdmin.company_type,@purchase_sale_detail.staff_id)
    respond_to do |format|
      format.html { redirect_to cold_storage_outwards_path, notice: 'Purchase sale detail was successfully destroyed.' }
      format.json { head :no_content }
      format.js   { render :layout => false }
    end
  end

  def stock_report_in_out
    pdf_rep = PurchaseSaleDetail.includes(:sys_user, purchase_sale_items: :product)
    in_report = pdf_rep.where(transaction_type: 'InWard').group('sys_users.name').sum('purchase_sale_items.quantity')
    out_report = pdf_rep.where(transaction_type: 'OutWard').group('sys_users.name').sum('purchase_sale_items.quantity')
    @pdf_inward_total = pdf_rep.where(transaction_type: 'InWard').sum('purchase_sale_items.quantity')
    @pdf_outward_total = pdf_rep.where(transaction_type: 'OutWard').sum('purchase_sale_items.quantity')
    @merged_hash = in_report.merge(out_report) do |key, oldval, newval|
      if oldval.is_a?(Array)
        oldval << newval
      elsif newval.is_a?(Array)
        newval << oldval
      else
        [oldval, newval]
      end
    end
    in_prod = pdf_rep.where(transaction_type: 'InWard').group('products.title', 'purchase_sale_items.size_8').sum('purchase_sale_items.quantity')
    out_prod = pdf_rep.where(transaction_type: 'OutWard').group('products.title', 'purchase_sale_items.size_8').sum('purchase_sale_items.quantity')
    @product_room_quantity = in_prod.merge(out_prod) { |key, a_val, b_val| a_val - b_val }
    generate_pdf('' ,'Stock-Report', 'pdf.html', 'A4', false, 'cold_storage_inwards/stock_report_in_out.pdf.erb')

  end

  private

  def set_cold_storage
    @purchase_sale_detail = PurchaseSaleDetail.find(params[:id])
  end

  def index_edit_new_data
    @orders = Order.all
    @customers = SysUser.where(:user_group=>['Customer','Both','Salesman'])
    @suppliers = SysUser.all
    @accounts = Account.all
    @products = Product.all
  end

  def index_data
    @users = PurchaseSaleDetail.pluck(:user_name).uniq
    @items = Item.all
    @staffs = Staff.loader_active_staff
    @total_stock = PurchaseSaleDetail.joins(:purchase_sale_items).includes(:purchase_sale_items).where(
      transaction_type: 'InWard').sum('purchase_sale_items.size_9')
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

  def create_data
    @sysuser = SysUser.find_by_id(purchase_sale_detail_params[:sys_user_id]).present? ? SysUser.find_by_id(purchase_sale_detail_params[:sys_user_id]) : SysUser.first
    @time = Time.zone.now
    @purchase_sale_detail = PurchaseSaleDetail.new(purchase_sale_detail_params)
    @id = PurchaseSaleDetail.where(created_at: Time.zone.now.beginning_of_day..Time.zone.now.end_of_day)
    @purchase_sale_detail.voucher_id = @id
    @purchase_sale_detail.user_name = current_user.name
  end

  def download_cold_storage_inwards_pdf_file
    @sys_users = @q.result
    sorted_inward_data
    generate_pdf(@sorted_data.as_json, 'Inward', 'pdf.html', 'A4', false, 'cold_storage_inwards/index.pdf.erb')
  end

  def download_inward_show_pdf_file
    sorted_inward_show_data
    generate_pdf(@sorted_data.as_json, 'Inward', 'pdf.html', 'A4', false, 'cold_storage_inwards/show.pdf.erb')
  end

  def purchase_sale_detail_params
    params.require(:purchase_sale_detail).permit(
      :sys_user_id,
      :transaction_type,
      :total_bill,
      :amount,
      :discount_price,
      :status, :comment,
      :voucher_id,
      :created_at,
      :account_id,
      :carriage,
      :loading,
      :order_id,
      :created_at,
      :staff_id,
      :bill_no,
      :user_name,
      :destination,
      :l_c,
      :g_d,
      :g_d_type,
      :g_d_date,
      :quantity,
      :dispatched_to,
      :despatch_date,
      :job_no,
      :reference_no,
      :company_name,
      :with_gst,
      purchase_sale_images: [],
      :purchase_sale_items_attributes => [
        :id,
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
        :size_1,:size_2,:size_3,:size_4,:size_5,:size_6,:size_7,:size_8,:size_9,:size_10,:size_11,:size_12,:size_13,
        :discount_price,
        :purchase_sale_type,
        :created_at,
        :expiry_date,
        :extra_expence,
        :extra_quantity,
        :gst,
        :gst_amount,
        :_destroy
      ],
      :expense_entries_attributes => [
        :id,
        :expense_id,
        :amount,
        :comment,
        :status,
        :account_id,
        :expense_type_id,
        :expenseable_type,
        :expenseable_id,
        :_destroy
      ],
      :product_warranties_attributes => [
        :id,
        :purchase_sale_detail_id,
        :product_id,
        :serial,
        :created_at,
        :_destroy
      ]
    )
  end
end