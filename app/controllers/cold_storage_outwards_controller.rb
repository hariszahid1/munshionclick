# frozen_string_literal: true

# FollowUps Controller
class ColdStorageOutwardsController < ApplicationController
  include PdfCsvGeneralMethod
  include OutwardsHelper
  before_action :set_cold_storage, only: %i[show edit update destroy]
  before_action :index_edit_new_data, only: %i[new show edit index]

  def index
    date_search
    index_data
    @q = PurchaseSaleDetail.includes(:order, :account, :sys_user,
                                     purchase_sale_items: :product).ransack(params[:q])
    purchase_sale_detail = @q.result.distinct.where(transaction_type: 'OutWard')
    @purchase_sale_details = purchase_sale_detail.order('purchase_sale_details.created_at desc').page(params[:page]).per(100)
    @pdf_orders = @q.result.where(transaction_type: 'OutWard')
    if params[:pdf].present?
      @pdf_orders_total = @pdf_orders.sum('purchase_sale_items.quantity')
      @pdf_orders_total_bill = @pdf_orders.sum('purchase_sale_items.total_pandri_bill')
      pdf_outward_q = @pdf_orders.group('sys_users.name').sum('purchase_sale_items.quantity')
      pdf_outward_t = @pdf_orders.group('sys_users.name').sum('purchase_sale_items.total_pandri_bill')
      @pdf_outward_total = pdf_outward_q.merge(pdf_outward_t) { |key, old_val, new_val| [old_val, new_val] }
      download_cold_storage_outwards_pdf_file
    end
  end

  def new
    @purchase_sale_details = PurchaseSaleDetail.all
    @purchase_sale_detail = PurchaseSaleDetail.new(order_id: params[:order_id],
                                                   sys_user_id: params[:sys_user_id])
    if params[:order_id].present?
      order=Order.find(params[:order_id])
      order.order_items.each do |ord|
        p_in_item = PurchaseSaleItem.find_by(product_id: ord.product_id, size_13: ord.marka,size_10: ord.challan_no, transaction_type: "Purchase")
        room_num = p_in_item.size_8
        rack_num = p_in_item.size_7
        in_date = p_in_item.purchase_sale_detail.created_at
        @purchase_sale_detail.purchase_sale_items.build(product_id: ord.product_id, size_13: ord.marka, size_10: ord.challan_no, size_8: room_num, size_7: rack_num, inward_date: in_date)
      end
    end
    @staffs = Staff.joins(:department).where('departments.active': true)

  end

  def edit
    @staffs = Staff.joins(:department).where('departments.active': true)

  end

  def create
    @pos_setting=PosSetting.first
    @sysuser=SysUser.find_by_id(purchase_sale_detail_params[:sys_user_id]).present? ? SysUser.find_by_id(purchase_sale_detail_params[:sys_user_id]) : SysUser.first
    balance = @sysuser.balance
    bill = purchase_sale_detail_params[:total_bill].to_f-purchase_sale_detail_params[:discount_price].to_f
    fullbalance=-bill+purchase_sale_detail_params[:amount].to_f+(balance.to_f)

    @time = Time.zone.now
    PurchaseSaleDetail.maximum(:id).present? ? psd= PurchaseSaleDetail.maximum(:id).next : psd=1
    @purchase_sale_detail = PurchaseSaleDetail.new(purchase_sale_detail_params)
    @id = PurchaseSaleDetail.where(created_at: Time.zone.now.beginning_of_day..Time.zone.now.end_of_day).count+1
    @purchase_sale_detail.voucher_id=@id
    @purchase_sale_detail.user_name=current_user.name
    respond_to do |format|
      if @purchase_sale_detail.save!
          @ledger_book = LedgerBook.new(sys_user_id: @sysuser.id,debit:purchase_sale_detail_params[:amount].to_f,credit:(bill),balance:fullbalance,comment:"Voucher #"+psd.to_s+"  ||  "+(purchase_sale_detail_params["created_at(3i)"])+"/"+(purchase_sale_detail_params["created_at(2i)"])+"/"+(purchase_sale_detail_params["created_at(1i)"])+" "+@time.strftime("at %I:%M%p"),purchase_sale_detail_id: @purchase_sale_detail.id)
          @ledger_book.save!
        if @purchase_sale_detail.staff_id.present?
          # @purchase_sale_detail.salary_detail_id=salary_detail.id
          staff=@purchase_sale_detail.staff
          staff.wage_debit += @purchase_sale_detail.carriage+@purchase_sale_detail.loading
          staff.balance += @purchase_sale_detail.carriage+@purchase_sale_detail.loading
          staff.save!
          @purchase_sale_detail.salary_details.create(staff_id: @purchase_sale_detail.staff_id, amount: @purchase_sale_detail.carriage, comment: "Carriage", total_balance: staff.balance-@purchase_sale_detail.loading,quantity: @purchase_sale_detail.purchase_sale_items_quantities, created_at: @purchase_sale_detail.created_at)
          @purchase_sale_detail.salary_details.create(staff_id: @purchase_sale_detail.staff_id, amount: @purchase_sale_detail.loading, comment: "Loading", total_balance: staff.balance,created_at: @purchase_sale_detail.created_at)
          # @purchase_sale_detail.save!
        end
        set_penalty_pandri(@purchase_sale_detail)
        format.html { redirect_to order_outwards_path, notice: 'Outward was successfully created.' }
      else
        format.html { render :new }
        format.json { render json: @purchase_sale_detail.errors, status: :unprocessable_entity }
      end
    end
  end

  def show
    download_outward_show_pdf_file if params[:pdf].present?
  end

  def update
    @pos_setting=PosSetting.first
    respond_to do |format|
      purchase = Hash.new
      @purchase_sale_detail.purchase_sale_items.each do |item|
        purchase[item.product_id]=item.quantity if item.product_id.present?
      end
      before_update_carriage_loading = @purchase_sale_detail.carriage+@purchase_sale_detail.loading
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
        if @purchase_sale_detail.salary_details.present?
          if @purchase_sale_detail.staff.present?
            staff=@purchase_sale_detail.staff
            staff.wage_debit = ((@purchase_sale_detail.carriage+@purchase_sale_detail.loading)-before_update_carriage_loading+staff.wage_debit)
            staff.balance = ((@purchase_sale_detail.carriage+@purchase_sale_detail.loading)-before_update_carriage_loading+staff.balance)
            staff.save!
            @purchase_sale_detail.salary_details.first.update(staff_id: @purchase_sale_detail.staff_id, amount: @purchase_sale_detail.carriage, comment: "Carriage" , total_balance: staff.balance-@purchase_sale_detail.loading,quantity: @purchase_sale_detail.purchase_sale_items_quantities, created_at: @purchase_sale_detail.created_at)
            @purchase_sale_detail.salary_details.last.update(staff_id: @purchase_sale_detail.staff_id, amount: @purchase_sale_detail.loading, comment: "Loading", total_balance: staff.balance,created_at: @purchase_sale_detail.created_at)
          end
        else
          # @purchase_sale_detail.salary_detail_id=salary_detail.id
          if @purchase_sale_detail.staff.present?
            staff=@purchase_sale_detail.staff
            staff.wage_debit = ((@purchase_sale_detail.carriage+@purchase_sale_detail.loading)-before_update_carriage_loading+staff.wage_debit)
            staff.balance = ((@purchase_sale_detail.carriage+@purchase_sale_detail.loading)-before_update_carriage_loading+staff.balance)
            staff.save!
            @purchase_sale_detail.salary_details.build(staff_id: @purchase_sale_detail.staff_id, amount: @purchase_sale_detail.carriage, comment: "Carriage", total_balance: staff.balance-@purchase_sale_detail.loading,quantity: @purchase_sale_detail.purchase_sale_items_quantities, created_at: @purchase_sale_detail.created_at)
            @purchase_sale_detail.salary_details.build(staff_id: @purchase_sale_detail.staff_id, amount: @purchase_sale_detail.loading, comment: "Loading", total_balance: staff.balance,created_at: @purchase_sale_detail.created_at)
          end
        end
        @purchase_sale_detail.save!
        UserLedgerBookJob.perform_later(current_user.superAdmin.company_type,@purchase_sale_detail.sys_user_id)
        AccountPaymentJob.perform_later(current_user.superAdmin.company_type,@purchase_sale_detail.account_id)
        SalaryDetailJob.perform_later(current_user.superAdmin.company_type,@purchase_sale_detail.staff_id)
        set_penalty_pandri(@purchase_sale_detail)
        format.html { redirect_to cold_storage_outwards_path, notice: 'Outward was successfully updated.' }
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

  def get_outward_storage_stock_data
    sys_user_id = params[:party_id]
    marka_no = params[:marka_no]
    challan_no = params[:challan_no]
    product_id = params[:product_id]
    rem_stock = PurchaseSaleItem.joins(:purchase_sale_detail).where('purchase_sale_details.sys_user_id': sys_user_id, 'purchase_sale_details.transaction_type': "OutWard", 'product_id': product_id, 'size_13': marka_no, 'size_10': challan_no).last&.size_6
    if rem_stock.present?
      stock = rem_stock
    else
      stock = PurchaseSaleItem.joins(:purchase_sale_detail).where('purchase_sale_details.sys_user_id': sys_user_id, 'purchase_sale_details.transaction_type': "InWard", 'product_id': product_id, 'size_13': marka_no, 'size_10': challan_no).pluck(:size_9)
    end
    respond_to do |format|
      format.json { render json: stock }
    end
  end
  private

  def set_cold_storage
    @purchase_sale_detail = PurchaseSaleDetail.find(params[:id])
  end

  def index_edit_new_data
    @orders = Order.all
    @customers = SysUser.all
    @suppliers = SysUser.where(:user_group=>['Supplier','Both','Own'])
    @accounts = Account.all
    @products = Product.all
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

  def index_data
    @users = PurchaseSaleDetail.pluck(:user_name).uniq
    @items = Item.all
    @staffs = Staff.loader_active_staff
    @total_stock = PurchaseSaleDetail.joins(:purchase_sale_items).includes(:purchase_sale_items).where(
      transaction_type: 'InWard').sum('purchase_sale_items.size_9')
  end

  def download_cold_storage_outwards_pdf_file
    @sys_users = @q.result
    sorted_outward_data
    generate_pdf(@sorted_data.as_json, 'Daily-basis-Outward', 'pdf.html', 'A4', false, 'cold_storage_outwards/index.pdf.erb')
  end

  def download_outward_show_pdf_file
    sorted_outward_show_data
    generate_pdf(@sorted_data.as_json, 'Outward', 'pdf.html', 'A4', false, 'cold_storage_outwards/show.pdf.erb')
  end

  def set_penalty_pandri(purchase_sale_detail)
    out_ward_date = purchase_sale_detail.created_at.to_date
    purchase_sale_detail.purchase_sale_items.each do |p_item|
      if out_ward_date.present? && p_item.closed_date.present?
        close_date =  p_item.closed_date&.to_date
        panelty = ((out_ward_date-close_date).to_f/15).ceil()
        total_bill = (p_item.rent_pandri.to_f*p_item.quantity.to_f*panelty.to_f)
        p_item.update(panelty_pandri: panelty, total_pandri_bill: total_bill)
      end
    end
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
        :inward_date,
        :closed_date,
        :rent_pandri,
        :panelty_pandri,
        :total_pandri_bill,
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