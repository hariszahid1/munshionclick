class OrderPurchasesController < ApplicationController
  before_action :set_order, only: [:show, :edit, :update, :destroy, :transfer, :booking_print, :booking_cancel]
  before_action :show_purchase_order, only: [:show, :booking_print]
  before_action :load_data, only: %i[index new edit transfer]
  skip_before_action :authenticate_user!, only: [:show]
  before_action :check_access
  before_action :set_user, only: %i[new edit]
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
    if params[:purchase_submit].present?
      download_index_pdf
    else
      if params[:product].present? || params[:product_type].present?
        @q = Order.where(transaction_type:"Purchase").joins(order_items: :product).includes(order_items: :product).ransack(params[:q])
      else
        @q = Order.where(transaction_type:"Purchase").joins(order_items: :item).includes(order_items: :item).ransack(params[:q])
      end
      @q.sorts = 'id desc' if @q.result.count > 0 && @q.sorts.empty?
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
    @item_types = ItemType.all
    @order.order_items.build
    @order.follow_ups.build
    @order.property_plans.build

    @items = Item.all
    @account = current_user.user_account
  end

    # POST /orders
  # POST /orders.json
  def create
    @order = Order.new(order_params)
    @pos_setting = PosSetting.first
    balance = LedgerBook.where(sys_user_id: order_params[:sys_user_id]).present? ? LedgerBook.where(sys_user_id: order_params[:sys_user_id]).last.balance : 0
    @sysuser = SysUser.find(order_params[:sys_user_id]).present? ? SysUser.find(order_params[:sys_user_id]) : SysUser.first
    balance = balance.zero? && @sysuser.present? ? @sysuser.opening_balance : 0
    bill = order_params[:total_bill].to_i-order_params[:discount_price].to_i
    fullbalance = order_params[:amount].to_i+(balance.to_i)
    @time = Time.zone.now
    psd = Order.maximum(:id).present? ? Order.maximum(:id).next : 1
    @id = Order.where(created_at: Time.zone.now.all_day).count + 1
    @order.voucher_id = @id
    respond_to do |format|
      if @order.save!
        PaymentBalanceJob.set(wait: 1.minutes).perform_later(current_user.superAdmin.company_type)
        if params[:commit] == "Save with Print"
          if @pos_setting.sys_type == "FastFood"
            format.html {render :partial => "/orders/fast_food/create"}
          elsif @pos_setting.sys_type != "MobileShop"
            request.format = 'pdf'
            format.pdf do
              print_pdf("Order Detail",'pdf.html','A8',true)
            end
          else
            request.format = 'pdf'
            format.pdf do
              print_pdf("Order Detail",'pdf.html','A4',true)
            end
          end
          if user_type(@sysuser.id) != 'Supplier'
            @ledger_book = LedgerBook.new(sys_user_id: @sysuser.id,debit:0,credit:order_params[:amount].to_i,balance:fullbalance,comment:"Booking #"+psd.to_s+"  ||  "+(order_params["created_at(3i)"])+"/"+(order_params["created_at(2i)"])+"/"+(order_params["created_at(1i)"])+" "+@time.strftime("at %I:%M%p"),order_id: @order.id)
            @ledger_book.save!
          else
            @ledger_book = LedgerBook.new(sys_user_id: @sysuser.id,debit:order_params[:amount].to_i,credit:0,balance:fullbalance,comment:"Booking #"+psd.to_s+"  ||  "+(order_params["created_at(3i)"])+"/"+(order_params["created_at(2i)"])+"/"+(order_params["created_at(1i)"])+" "+@time.strftime("at %I:%M%p"),order_id: @order.id)
            @ledger_book.save!
          end
          format.html { redirect_to new_order_purchase_path(transaction_type: :sale,product: true), notice: 'Sale Order was successfully created.' }
        else
          @ledger_book = LedgerBook.new(sys_user_id: @sysuser.id,debit:0,credit:order_params[:amount].to_i,balance:fullbalance,comment:"Booking #"+psd.to_s+"  ||  "+(order_params["created_at(3i)"])+"/"+(order_params["created_at(2i)"])+"/"+(order_params["created_at(1i)"])+" "+@time.strftime("at %I:%M%p"),order_id: @order.id,account_id: @order.account_id)
          @ledger_book.save!
          format.html { redirect_to order_purchases_path(product: true), notice: 'Purchase Order was successfully created.' }
        end
        format.json { render :show, status: :created, location: @order }
        if @pos_setting.sms_templates.present?
          send_sms(@order.sys_user&.contact&.phone_with_comma,@pos_setting.sms_templates["new_order"],'','') if @pos_setting.sms_templates["new_order"].present?
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
    @product_detail = order_product_detail
    if params[:page_size].present? && params[:style].present?
      print_pdf(@order&.sys_user&.name.to_s+" Order-Detail",'pdf.html','A3')
    elsif params[:page_size].present?
      print_pdf(@order&.sys_user&.name.to_s+" Order-Detail",'pdf.html','A3')
    elsif @pos_setting.sys_type == "FastFood"
      render :partial => "/orders/fast_food/create"
    else
      print_pdf(@order&.sys_user&.name.to_s+" Order-Detail",'pdf.html','A4')
    end
  end

  def booking_print
    @product_detail = order_product_detail
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
    redirect_to order_purchases_path(sale: :true)
  end

  # GET /orders/1/edit
  def edit
    @items = Item.all
    @item_types = ItemType.all
    @order.order_items.build if @pos_setting.sys_type == "FastFood"
  end


  # PATCH/PUT /orders/1
  # PATCH/PUT /orders/1.json
  def update
    @pos_setting = PosSetting.first
    if params[:commit] == "Transfer"
      order_params[:remarks_attributes].each do |a|
        @order.sys_user.update(name:a.last[:body]) if a.last[:body].present?
      end

      # order.sys_user.name=
    end
    respond_to do |format|
      if @order.update!(order_params)
        @order.update(status: 'UnPrint')
        if params[:commit] == "Save with Print"
          if @pos_setting.sys_type == "FastFood"
            format.html {render :partial => "/orders/fast_food/create"}
          else
            request.format = 'pdf'
            format.pdf do
              print_pdf("Order Detail",'pdf.html','A4')
            end
          end
        end

        UserLedgerBookJob.perform_later(current_user.superAdmin.company_type,@order.sys_user_id)
        AccountPaymentJob.perform_later(current_user.superAdmin.company_type,@order.account_id)

        format.html { redirect_to order_purchases_path, notice: 'Purchase order was successfully updated.' }
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
      format.html { redirect_to orders_path, notice: 'Purchase Order detail was successfully destroyed.' }
      format.json { head :no_content }
      format.js   { render :layout => false }

    end
  end

  def transfer
    @items = Item.all
    @item_types = ItemType.all
    @order.remarks.build

    @sys_user = @order.sys_user
    @user_types=UserType.all
    @cities = City.all
    @countries = Country.all

  end

  # GET /orders
  # GET /orders.json
  def auto_print
    @user_types = UserType.all
    @users = SysUser.where(user_group: %w[Customer Salesman])
    @user_list = {}
    @user_active = {}
    @user_types.each do |user_type|
      @user_list[user_type.id] = @users.where(user_type_id: user_type.id)
    end
    @unprint = Order.where(status: 'UnPrint')
    @users.each do |user|
      @user_active[user.id] = if user.orders.present?
                                if user.orders&.last&.purchase_sale_details.present?
                                  0
                                elsif user.orders&.last.status != 'UnPrint'
                                  2
                                else
                                  1
                                end
                              else
                                0
                              end
    end

    @q = Order.where(transaction_type: 'Sale').ransack(params[:q])
  end

  def print_bulk
    @user_types = UserType.all
    @users = SysUser.where(user_group: %w[Customer Salesman])
    @user_list = {}
    @user_active = {}
    @user_types.each do |user_type|
      @user_list[user_type.id] = @users.where(user_type_id: user_type.id)
    end
    @orders = Order.where(status: 'UnPrint')
    @users.each do |user|
      if user.orders.present?
        if user.orders&.last&.purchase_sale_details.present?
          @user_active[user.id] = 0
        elsif user.orders&.last.status != 'UnPrint'
          @user_active[user.id] = 2
          order = user.orders&.last
          order.update(status: 'UnClear') if order.present?
        else
          @user_active[user.id] = 1
        end
      else
        @user_active[user.id] = 0
      end
    end

    if @orders.present?
      print_pdf('Order Detail', 'order_bulk.pdf.erb', 'A8', true)
    else
      redirect_to auto_print_orders_path
    end
  end

  def booking_reciept
    @order = Order.find(params[:order_id])
    request.format = 'pdf'
    respond_to do |format|
      format.html
      format.pdf do
        render pdf: 'booking_reciept',
               template: 'orders/booking_reciept.pdf.erb',
               page_size: 'A4',
               orientation: 'Portrait',
               margin: {
                 margin_top: @pos_setting&.pdf_margin_top.to_f,
                 margin_right: @pos_setting&.pdf_margin_right.to_f,
                 margin_bottom: @pos_setting&.pdf_margin_bottom.to_f,
                 margin_left: @pos_setting&.pdf_margin_left.to_f
               },
               encoding: 'UTF-8',
               footer: {
                 right: '[page] of [topage]'
               },
               show_as_html: false
      end
    end
  end

  def dynamic_pdf
    @order = Order.find(params[:order_id])
    @products = Product.all
    @created_at_gteq = DateTime.current.beginning_of_month
    @created_at_lteq = DateTime.now
    if params[:sale].present?
      @products_sale = OrderItem.joins(:product).where(product_id: @products, created_at: @created_at_gteq.to_date.beginning_of_day..@created_at_lteq.to_date.end_of_day).group(:title).sum(:total_sale_price)
      @products_sale_total = OrderItem.joins(:product).where(product_id: @products, created_at: @created_at_gteq.to_date.beginning_of_day..@created_at_lteq.to_date.end_of_day).sum(:total_sale_price)
      @products_count = OrderItem.joins(:product).where(product_id: @products, created_at: @created_at_gteq.to_date.beginning_of_day..@created_at_lteq.to_date.end_of_day,transaction_type: "Sale").group(:title).sum(:quantity)
    else
      @products_sale = OrderItem.joins(:product).where(product_id: @products, created_at: @created_at_gteq.to_date.beginning_of_day..@created_at_lteq.to_date.end_of_day).group(:title).sum(:total_cost_price)
      @products_sale_total = OrderItem.joins(:product).where(product_id: @products, created_at: @created_at_gteq.to_date.beginning_of_day..@created_at_lteq.to_date.end_of_day).sum(:total_cost_price)
      @products_count = OrderItem.joins(:product).where(product_id: @products, created_at: @created_at_gteq.to_date.beginning_of_day..@created_at_lteq.to_date.end_of_day,transaction_type: "Purchase").group(:title).sum(:quantity)
    end

    @pdf_template = PdfTemplate.includes(:pdf_template_elements).find_by(table_name: 'order', method_name: 'index')
    @pdf_header = @pdf_template&.pdf_template_elements&.find_by(title: 'pdf_header')
    @account_statement = @pdf_template&.pdf_template_elements&.find_by(title: 'account_statement')
    @property_details = @pdf_template&.pdf_template_elements&.find_by(title: 'property_details')
    @payment_details = @pdf_template&.pdf_template_elements&.find_by(title: 'payment_details')
    @property_plans = @pdf_template&.pdf_template_elements&.find_by(title: 'property_plans')
    @delivery_details = @pdf_template&.pdf_template_elements&.find_by(title: 'delivery_details')
    @transfer_details = @pdf_template&.pdf_template_elements&.find_by(title: 'transfer_details')
    @web_links = @pdf_template&.pdf_template_elements&.find_by(title: 'web_links')
    @booking_qr = @pdf_template&.pdf_template_elements&.find_by(title: 'booking_qr')
    @account_signature = @pdf_template&.pdf_template_elements&.find_by(title: 'account_signature')
    @booking_qr_else = @pdf_template&.pdf_template_elements&.find_by(title: 'booking_qr_else')
    @company_signature = @pdf_template&.pdf_template_elements&.find_by(title: 'company_signature')
    @pdf_footer = @pdf_template&.pdf_template_elements&.find_by(title: 'pdf_footer')

    @pos_setting = PosSetting.first

    request.format = 'pdf'
    respond_to do |format|
      format.html
      format.pdf do
        render pdf: 'order-dynamic-pdf',
               template: 'orders/dynamic_pdf.pdf.erb',
               page_size: 'A4',
               orientation: 'Portrait',
               margin: {
                 margin_top: @pos_setting&.pdf_margin_top.to_f,
                 margin_right: @pos_setting&.pdf_margin_right.to_f,
                 margin_bottom: @pos_setting&.pdf_margin_bottom.to_f,
                 margin_left: @pos_setting&.pdf_margin_left.to_f
               },
               encoding: 'UTF-8',
               footer: {
                 right: '[page] of [topage]'
               },
               show_as_html: false
      end
    end
  end

  def view_history
    @start_date = Date.today.beginning_of_month
    @end_date = Date.today.end_of_month
    if params[:q].present?
      @start_date = params[:q][:created_at_gteq] if params[:q][:created_at_gteq].present?
      @end_date = params[:q][:created_at_lteq] if params[:q][:created_at_lteq].present?
      @item_id = params[:q][:item_id_eq] if params[:q][:item_id_eq].present?
      if params[:q][:created_at_lteq].present?
        params[:q][:created_at_lteq] =
          params[:q][:created_at_lteq].to_date.end_of_day
      end
    end
    @event = %w[create update destroy]
    @q = PaperTrail::Version.where(item_id: Order.where(transaction_type: 'Purchase'),
                                   item_type: 'Order').order('created_at desc').ransack(params[:q])
                                                                  
    @order_logs = @q.result.page(params[:page])
    respond_to do |format|
      format.js
    end
  end

  def user_type(id)
    SysUser.find(id).user_group
  end

  private

    # Use callbacks to share common setup or constraints between actions.
    def set_order
      @order = Order.find(params[:id])
    end

    def load_data
      @items = Item.all
      @products = Product.all
      @accounts = Account.all
      @suppliers = SysUser.where(user_group: %w[Supplier Both Own])
      @customers = SysUser.where(user_group: %w[Customer Supplier Both Salesman])
    end

    def show_purchase_order
      @products = Product.all
      @created_at_gteq = DateTime.current.beginning_of_month
      @created_at_lteq = DateTime.now
      if params[:q].present?
        @created_at_gteq = params[:q][:created_at_gteq] if params[:q][:created_at_gteq].present?
        @created_at_lteq = params[:q][:created_at_lteq] if params[:q][:created_at_lteq].present?
        params[:q][:created_at_lteq] = params[:q][:created_at_lteq].to_date.end_of_day if params[:q][:created_at_lteq].present?
      end
      if params[:purchase_submit].present?
        product_id = params[:q][:purchase_sale_items_product_product_id].present? ? params[:q][:purchase_sale_items_product_product_id] : @products
        @products_sale =  OrderItem.joins(:product).where(product_id:product_id, created_at: @created_at_gteq.to_date.beginning_of_day..@created_at_lteq.to_date.end_of_day).group(:title).sum(:total_cost_price)
        @products_sale_total =  OrderItem.joins(:product).where(product_id:product_id, created_at: @created_at_gteq.to_date.beginning_of_day..@created_at_lteq.to_date.end_of_day).sum(:total_cost_price)
        @products_count = OrderItem.joins(:product).where(product_id:product_id, created_at: @created_at_gteq.to_date.beginning_of_day..@created_at_lteq.to_date.end_of_day,transaction_type: "Purchase").group(:title).sum(:quantity)
      else
        if params[:purchase_sale_details].present?
          @q = Order.where(:transaction_type=>"Purchase").ransack(params[:q])
        else
          @q = Order.where(:transaction_type=>"Purchase").ransack(params[:q])
          @accounts=Account.all
        end
        @q.sorts = 'id desc' if @q.result.count > 0 && @q.sorts.empty?
        @orders = @q.result.page(params[:page])
        @suppliers = SysUser.where(user_group: %w[Supplier Both Own])
        @customers = SysUser.where(user_group: %w[Customer Supplier Both Salesman])
      end
    end

    def order_product_detail
      item_data = Order.joins(order_items: :product).includes(order_items: :product).find_by(id: @order.id)
      item_data = Order.joins(order_items: :item).includes(order_items: :item).find_by(id: @order.id) if item_data.blank?
      product_detail = []
      if item_data.present? && item_data.order_items.present?
        item_data.order_items.each do |item|
          if item.product_id.present?
            product_detail << [item.product&.title, item.quantity, item.cost_price, item.total_cost_price, item.expiry_date,item.product&.category_title,item.product&.item_type&.title,item.product&.code,item.marla,item.square_feet]
          else
            product_detail << [item.item&.title, item.quantity, item.cost_price, item.total_cost_price, item.expiry_date,item.item&.item_type&.title]
          end
        end
        return product_detail
      else
        return 0
      end
    end

    def download_index_pdf
      if params[:product_type].eql?('true')
        product_id = Product.joins(order_items: :order).where("orders.transaction_type": "Purchase")
        @products_sale =  OrderItem.joins(:product).where(product_id:product_id, created_at: @created_at_gteq.to_date.beginning_of_day..@created_at_lteq.to_date.end_of_day).group(:title).sum(:total_cost_price)
        @products_sale_total =  OrderItem.joins(:product).where(product_id:product_id, created_at: @created_at_gteq.to_date.beginning_of_day..@created_at_lteq.to_date.end_of_day).sum(:total_cost_price)
        @products_count = OrderItem.joins(:product).where(product_id:product_id, created_at: @created_at_gteq.to_date.beginning_of_day..@created_at_lteq.to_date.end_of_day,transaction_type: "Purchase").group(:title).sum(:quantity)
      else
        item_id = Item.all
        @products_sale =  OrderItem.joins(:item).where(item_id:item_id, created_at: @created_at_gteq.to_date.beginning_of_day..@created_at_lteq.to_date.end_of_day).group(:title).sum(:total_cost_price)
        @products_sale_total =  OrderItem.joins(:item).where(item_id:item_id, created_at: @created_at_gteq.to_date.beginning_of_day..@created_at_lteq.to_date.end_of_day).sum(:total_cost_price)
        @products_count = OrderItem.joins(:item).where(item_id:item_id, created_at: @created_at_gteq.to_date.beginning_of_day..@created_at_lteq.to_date.end_of_day,transaction_type: "Purchase").group(:title).sum(:quantity)
      end
      request.format = 'pdf'
      print_pdf("Orders Detail",'pdf.html','A4')
    end

    def set_user
      created_by_ids = current_user&.created_by_ids_list_to_view
      roles_mask = current_user&.allowed_to_view_roles_mask_for
      @users = User.where(roles_mask: roles_mask).where('company_type=? or created_by_id=?', current_user&.company_type,
                                                        created_by_ids)
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
        remarks_attributes: %i[
          id
          user
          body
          message
          comment
          remark_type
          remarkable_type
          remarkable_id
        ],
        order_items_attributes: %i[
          id
          gst
          gst_amount
          purchase_sale_detail_id
          item_id
          product_id
          quantity
          cost_price
          sale_price
          status
          comment
          total_cost_price
          total_sale_price
          transaction_type
          discount_price
          purchase_sale_type
          created_at
          expiry_date
          extra_expence
          marla
          square_feet
          _destroy
        ],
        links_attributes: %i[
          id
          qrcode
          brcode
          herf
          title
          _destroy
        ],
        property_plans_attributes: [
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
          { property_installments_attributes: %i[
            id
            property_plan_id
            installment_no
            installment_price
            high_price
            normal_price
            created_at
            updated_at
            due_date
            due_status
            payment_method
            bank_detail
            _destroy
          ] }
        ],
        follow_ups_attributes: [
          :id,
          :reminder_type,
          :task_type,
          :priority,
          :created_by,
          :assigned_to_id,
          :date,
          :comment,
          :followable_id,
          :followable_type
        ]
      )
    end

end