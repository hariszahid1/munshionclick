class OrderSalesController < ApplicationController
  before_action :set_order, only: [:show, :edit, :update, :destroy, :transfer, :booking_print, :booking_cancel]
  before_action :show_sale_order, only: [:show, :booking_print]
  before_action :load_data, only: %i[index new edit transfer]
  before_action :find_items, only: %i[new edit transfer]
  skip_before_action :authenticate_user!, only: [:show]

  # GET /orders
  # GET /orders.json
  def index
    @created_at_gteq = DateTime.current.beginning_of_month
    @created_at_lteq = DateTime.now
    if params[:q].present?
      @created_at_gteq = params[:q][:created_at_gteq] if params[:q][:created_at_gteq].present?
      @created_at_lteq = params[:q][:created_at_lteq] if params[:q][:created_at_lteq].present?
      params[:q][:created_at_lteq] = params[:q][:created_at_lteq].to_date.end_of_day if params[:q][:created_at_lteq].present?
    end
    if params[:sale_submit].present?
      download_index_pdf
    else
      @q = Order.where(:transaction_type => 'Sale').ransack(params[:q])
      if @q.result.count > 0
        @q.sorts = 'id desc' if @q.sorts.empty?
      end
      @orders = @q.result.page(params[:page])
    end
  end

  # GET /orders/new
  def new
    if params[:order].present?
      @order = Order.new(order_params)
    else
      @order = Order.new
    end
    @order.order_items.build
    @order.property_plans.build
    @account = current_user.user_account
  end

  def create
    @order = Order.new(order_params)
    @pos_setting = PosSetting.first
    balance = LedgerBook.where(sys_user_id: order_params[:sys_user_id]).present? ? LedgerBook.where(sys_user_id: order_params[:sys_user_id]).last.balance : 0
    @sysuser = SysUser.find(order_params[:sys_user_id]).present? ? SysUser.find(order_params[:sys_user_id]) : SysUser.first
    balance = balance.zero? && @sysuser.present? ? @sysuser.opening_balance : 0
    bill = order_params[:total_bill].to_i - order_params[:discount_price].to_i
    full_balance = order_params[:amount].to_i + balance.to_i
    @time = Time.zone.now
    psd = Order.maximum(:id).present? ? Order.maximum(:id).next : 1
    @id = Order.where(created_at: Time.zone.now.all_day).count + 1
    @order.voucher_id = @id
    respond_to do |format|
      if @order.save!
        PaymentBalanceJob.set(wait: 1.minutes).perform_later(current_user.superAdmin.company_type)
        if params[:commit].eql?('Save with Print')
          if @pos_setting.sys_type.eql?('FastFood')
            format.html { render :partial => '/order_sales/fast_food/create' }
          else
            page_size = @pos_setting.sys_type != 'MobileShop' ? 'A8' : 'A4'
            request.format = 'pdf'
            format.pdf do
              print_pdf('Order Detail', 'pdf.html', page_size, true)
            end
          end
          debit_and_credit = user_type(@sysuser.id) != 'Supplier' ? [0, order_params[:amount].to_i] : [order_params[:amount].to_i, 0]
          @ledger_book = LedgerBook.new(sys_user_id: @sysuser.id, debit: debit_and_credit.first, credit: debit_and_credit.last, balance: full_balance, comment: "Booking #"+psd.to_s+"  ||  "+(order_params["created_at(3i)"])+"/"+(order_params["created_at(2i)"])+"/"+(order_params["created_at(1i)"]) + " "+ @time.strftime("at %I:%M%p"), order_id: @order.id)
          @ledger_book.save!
          format.html { redirect_to new_order_sale_path(transaction_type: :sale,product: true), notice: 'Sale Order was successfully created.' }
        else
          @ledger_book = LedgerBook.new(sys_user_id: @sysuser.id,debit:0,credit:order_params[:amount].to_i,balance:full_balance,comment:"Booking #"+psd.to_s+"  ||  "+(order_params["created_at(3i)"])+"/"+(order_params["created_at(2i)"])+"/"+(order_params["created_at(1i)"])+" "+@time.strftime("at %I:%M%p"),order_id: @order.id,account_id: @order.account_id)
          @ledger_book.save!
          format.html { redirect_to order_sales_path, notice: 'Sale Order was successfully created.' }
        end
        format.json { render :show, status: :created, location: @order }
        if @pos_setting.sms_templates.present? && @pos_setting.sms_templates['new_order'].present?
          send_sms(@order.sys_user&.contact&.phone_with_comma, @pos_setting.sms_templates["new_order"], '', '')
        end
      else
        format.html { render :new }
        format.json { render json: @order.errors, status: :unprocessable_entity }
      end
    end
  end

  # GET /orders/1
  # GET /orders/1.json
  def show
    if @pos_setting.sys_type.eql?('FastFood')
      render :partial => '/order_sales/fast_food/create'
    else
      page_size = params[:page_size].present? ? 'A3' : 'A4'
      print_pdf(@order&.sys_user&.name.to_s + ' Order-Detail', 'pdf.html', page_size)
    end
  end

  # GET /orders/1/edit
  def edit
    @order.order_items.build if @pos_setting.sys_type.eql?('FastFood')
  end

  # PATCH/PUT /orders/1
  # PATCH/PUT /orders/1.json
  def update
    @pos_setting = PosSetting.first
    if params[:commit].eql?('Transfer')
      order_params[:remarks_attributes].each do |order|
        @order.sys_user.update(name: order.last[:body]) if order.last[:body].present?
      end
    end
    respond_to do |format|
      if @order.update!(order_params)
        @order.update(status: 'UnPrint')
        if params[:commit].eql?('Save with Print')
          if @pos_setting.sys_type.eql?('FastFood')
            format.html {render :partial => "/orders/fast_food/create"}
          else
            request.format = 'pdf'
            format.pdf do
              print_pdf('Order Detail', 'pdf.html', 'A4')
            end
          end
        end

        UserLedgerBookJob.perform_later(current_user.superAdmin.company_type,@order.sys_user_id)
        AccountPaymentJob.perform_later(current_user.superAdmin.company_type,@order.account_id)

        if @order.transaction_type=='Sale'
          if @pos_setting.sys_type=="FastFood"
            format.html { redirect_to biller_order_sales_path(sale: :true), notice: 'Sale order detail was successfully updated.' }
          else
            format.html { redirect_to order_sales_path(sale: :true), notice: 'Sale order detail was successfully updated.' }
          end
          if @pos_setting.sms_templates.present?
            send_sms(@order.sys_user&.contact&.phone_with_comma,@pos_setting.sms_templates["update_order"],'','') if @pos_setting.sms_templates["update_order"].present?
          end
        end
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
    @order.destroy if @order.present?
    UserLedgerBookJob.perform_later(current_user.superAdmin.company_type,@order.sys_user_id)
    AccountPaymentJob.perform_later(current_user.superAdmin.company_type,@order.account_id)

    respond_to do |format|
      format.html { redirect_to order_sales_path(sale: :true), notice: 'Purchase Order detail was successfully destroyed.' }
      format.json { head :no_content }
      format.js   { render :layout => false }
    end

  end

  def booking_print
    print_pdf("Booking Detail",'pdf_styleless.html','legal')
  end

  def booking_cancel
    if @order.status != 'Cancel'
      @order.update(status: 'Cancel')
      @order.order_items.update_all(status: :open)
    else
      @order.update(status: 'Clear')
      @order.order_items.update_all(status:nil)
    end
    redirect_to order_sales_path(sale: :true)
  end

  def transfer
    @order.remarks.build
    @sys_user = @order.sys_user
    @user_types = UserType.all
    @cities = City.all
    @countries = Country.all
  end

  # GET /orders
  # GET /orders.json
  def biller
    @user_types = UserType.all
    @users = SysUser.where(:user_group=>['Customer','Salesman'])
    @user_list = Hash.new
    @user_active = Hash.new
    @user_types.each do |user_type|
      @user_list[user_type.id] = @users.where(user_type_id:user_type.id)
    end
    @users.each do |user|
      if user.orders.present?
        @user_active[user.id] = user.orders&.last&.purchase_sale_details.present? ? 0 : 1
      else
        @user_active[user.id] = 0
      end

    end
  end

  private

    def user_type(id)
      SysUser.find(id).user_group
    end

    # Use callbacks to share common setup or constraints between actions.
    def set_order
      @order = Order.find(params[:id])
    end

    def load_data
      @products = Product.all
      @accounts = Account.all
      @suppliers = SysUser.where(user_group: %w[Supplier Both Own])
      @customers = SysUser.where(user_group: %w[Customer Supplier Both Salesman])
    end

    def find_items
      @items = Item.all
      @item_types = ItemType.all
    end

    def show_sale_order
      @products=Product.all
      @created_at_gteq = DateTime.current.beginning_of_month
      @created_at_lteq = DateTime.now
      if params[:q].present?
        @created_at_gteq = params[:q][:created_at_gteq] if params[:q][:created_at_gteq].present?
        @created_at_lteq = params[:q][:created_at_lteq] if params[:q][:created_at_lteq].present?
        params[:q][:created_at_lteq] = params[:q][:created_at_lteq].to_date.end_of_day if params[:q][:created_at_lteq].present?
      end
      if params[:sale_submit].present?
        product_id= params[:q][:purchase_sale_items_product_product_id].present? ? params[:q][:purchase_sale_items_product_product_id] : @products
        if params[:sale_submit].present?
          @products_sale =  OrderItem.joins(:product).where(product_id:product_id, created_at: @created_at_gteq.to_date.beginning_of_day..@created_at_lteq.to_date.end_of_day).group(:title).sum(:total_sale_price)
          @products_sale_total =  OrderItem.joins(:product).where(product_id:product_id, created_at: @created_at_gteq.to_date.beginning_of_day..@created_at_lteq.to_date.end_of_day).sum(:total_sale_price)
          @products_count = OrderItem.joins(:product).where(product_id:product_id, created_at: @created_at_gteq.to_date.beginning_of_day..@created_at_lteq.to_date.end_of_day,transaction_type: "Sale").group(:title).sum(:quantity)
        end
      else
        if params[:purchase_sale_details].present?
           @q = Order.where(:transaction_type=>"Sale").ransack(params[:q])
        else
          @q = Order.where(:transaction_type=>"Sale").ransack(params[:q])
          @accounts=Account.all
        end
        if @q.result.count > 0
          @q.sorts = 'id desc' if @q.sorts.empty?
        end
        @orders = @q.result.page(params[:page])
        @suppliers=SysUser.where(:user_group=>['Supplier','Both', 'Own'])
        @customers=SysUser.where(:user_group=>['Customer','Supplier','Both','Salesman'])
      end
    end

    def download_index_pdf
      product_id = params[:q][:purchase_sale_items_product_product_id].present? ? params[:q][:purchase_sale_items_product_product_id] : @products
      @products_sale = OrderItem.joins(:product).where(product_id: product_id, created_at: @created_at_gteq.to_date.beginning_of_day..@created_at_lteq.to_date.end_of_day).group(:title).sum(:total_sale_price)
      @products_sale_total = OrderItem.joins(:product).where(product_id: product_id, created_at: @created_at_gteq.to_date.beginning_of_day..@created_at_lteq.to_date.end_of_day).sum(:total_sale_price)
      @products_count = OrderItem.joins(:product).where(product_id: product_id, created_at: @created_at_gteq.to_date.beginning_of_day..@created_at_lteq.to_date.end_of_day, transaction_type: 'Sale').group(:title).sum(:quantity)
      request.format = 'pdf'
      print_pdf("Orders Detail",'pdf.html','A4')
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
          :_destroy
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
end