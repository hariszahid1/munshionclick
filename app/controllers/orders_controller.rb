class OrdersController < ApplicationController
  before_action :set_order, only: [:show, :edit, :update, :destroy, :transfer, :booking_print, :booking_cancel]
  skip_before_action :authenticate_user!, only: [:show]

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

  # GET /orders
  # GET /orders.json
  def auto_print
    @user_types = UserType.all
    @users = SysUser.where(:user_group=>['Customer','Salesman'])
    @user_list = Hash.new
    @user_active = Hash.new
    @user_types.each do |user_type|
      @user_list[user_type.id] = @users.where(user_type_id:user_type.id)
    end
    @unprint = Order.where(status:'UnPrint')
    @users.each do |user|
      if user.orders.present?
        if user.orders&.last&.purchase_sale_details.present?
          @user_active[user.id] = 0
        elsif (user.orders&.last.status != 'UnPrint')
            @user_active[user.id] = 2
        else
          @user_active[user.id] = 1
        end
      else
        @user_active[user.id] = 0
      end
    end

    @q = Order.where(:transaction_type=>"Sale").ransack(params[:q])
    # if params[:submit_pdf_staff_without_bulk].present?
    #   respond_to do |format|
    #     request.format = 'pdf'
    #     format.html
    #     format.pdf do
    #       @pos_setting=PosSetting.first
    #       render pdf: 'Un Print list',
    #       layout: 'order_bulk.pdf',
    #       page_size: 'A4',
    #       margin_top: '0',
    #       margin_right: '0',
    #       margin_bottom: '0',
    #       margin_left: '0',
    #       footer:  {             # optional, use 'pdf_plain' for a pdf_plain.html.pdf.erb file, defaults to main layout
    #         right: '[page] of [topage]'},
    #       show_as_html: false
    #     end
    #   end
    # end
  end

  def print_bulk
    @user_types = UserType.all
    @users = SysUser.where(:user_group=>['Customer','Salesman'])
    @user_list = Hash.new
    @user_active = Hash.new
    @user_types.each do |user_type|
      @user_list[user_type.id] = @users.where(user_type_id:user_type.id)
    end
    @orders = Order.where(status: 'UnPrint')
    @users.each do |user|
      if user.orders.present?
        if user.orders&.last&.purchase_sale_details.present?
          @user_active[user.id] = 0
        elsif (user.orders&.last.status != 'UnPrint')
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
      print_pdf("Order Detail",'order_bulk.pdf.erb','A8',true)
    else
      redirect_to auto_print_orders_path
    end
  end

  # GET /orders
  # GET /orders.json
  def index
    @created_at_gteq = DateTime.current.beginning_of_month
    @created_at_lteq = DateTime.now
    @accounts=Account.all
    @products=Product.all
    @suppliers=SysUser.where(:user_group=>['Supplier','Both', 'Own'])
    @customers=SysUser.where(:user_group=>['Customer','Supplier','Both','Salesman'])
    if params[:q].present?
      @created_at_gteq = params[:q][:created_at_gteq] if params[:q][:created_at_gteq].present?
      @created_at_lteq = params[:q][:created_at_lteq] if params[:q][:created_at_lteq].present?
      params[:q][:created_at_lteq] = params[:q][:created_at_lteq].to_date.end_of_day if params[:q][:created_at_lteq].present?
    end
    if params[:purchase_submit].present? or params[:sale_submit].present?
      product_id= params[:q][:purchase_sale_items_product_product_id].present? ? params[:q][:purchase_sale_items_product_product_id] : @products
      if params[:sale_submit].present?
        @products_sale =  OrderItem.joins(:product).where(product_id:product_id, created_at: @created_at_gteq.to_date.beginning_of_day..@created_at_lteq.to_date.end_of_day).group(:title).sum(:total_sale_price)
        @products_sale_total =  OrderItem.joins(:product).where(product_id:product_id, created_at: @created_at_gteq.to_date.beginning_of_day..@created_at_lteq.to_date.end_of_day).sum(:total_sale_price)
        @products_count = OrderItem.joins(:product).where(product_id:product_id, created_at: @created_at_gteq.to_date.beginning_of_day..@created_at_lteq.to_date.end_of_day,transaction_type: "Sale").group(:title).sum(:quantity)
      else
        @products_sale =  OrderItem.joins(:product).where(product_id:product_id, created_at: @created_at_gteq.to_date.beginning_of_day..@created_at_lteq.to_date.end_of_day).group(:title).sum(:total_cost_price)
        @products_sale_total =  OrderItem.joins(:product).where(product_id:product_id, created_at: @created_at_gteq.to_date.beginning_of_day..@created_at_lteq.to_date.end_of_day).sum(:total_cost_price)
        @products_count = OrderItem.joins(:product).where(product_id:product_id, created_at: @created_at_gteq.to_date.beginning_of_day..@created_at_lteq.to_date.end_of_day,transaction_type: "Purchase").group(:title).sum(:quantity)
      end
      request.format = 'pdf'
      print_pdf("Orders Detail",'pdf.html','A4')
    else
      if params[:purchase_sale_details].present?
        params[:sale].present? ? @q = Order.where(:transaction_type=>"Sale").ransack(params[:q]) : @q = Order.where(:transaction_type=>"Purchase").ransack(params[:q])
      else
        params[:sale].present? ? @q = Order.where(:transaction_type=>"Sale").ransack(params[:q]) : @q = Order.where(:transaction_type=>"Purchase").ransack(params[:q])
      end
      if @q.result.count > 0
        @q.sorts = 'id desc' if @q.sorts.empty?
      end
      @orders = @q.result.page(params[:page])
    end
  end

  # GET /orders/1
  # GET /orders/1.json
  def show
    @products=Product.all
    @created_at_gteq = DateTime.current.beginning_of_month
    @created_at_lteq = DateTime.now
    if params[:q].present?
      @created_at_gteq = params[:q][:created_at_gteq] if params[:q][:created_at_gteq].present?
      @created_at_lteq = params[:q][:created_at_lteq] if params[:q][:created_at_lteq].present?
      params[:q][:created_at_lteq] = params[:q][:created_at_lteq].to_date.end_of_day if params[:q][:created_at_lteq].present?
    end
    if params[:purchase_submit].present? or params[:sale_submit].present?

      product_id= params[:q][:purchase_sale_items_product_product_id].present? ? params[:q][:purchase_sale_items_product_product_id] : @products
      if params[:sale_submit].present?
        @products_sale =  OrderItem.joins(:product).where(product_id:product_id, created_at: @created_at_gteq.to_date.beginning_of_day..@created_at_lteq.to_date.end_of_day).group(:title).sum(:total_sale_price)
        @products_sale_total =  OrderItem.joins(:product).where(product_id:product_id, created_at: @created_at_gteq.to_date.beginning_of_day..@created_at_lteq.to_date.end_of_day).sum(:total_sale_price)
        @products_count = OrderItem.joins(:product).where(product_id:product_id, created_at: @created_at_gteq.to_date.beginning_of_day..@created_at_lteq.to_date.end_of_day,transaction_type: "Sale").group(:title).sum(:quantity)
      else
        @products_sale =  OrderItem.joins(:product).where(product_id:product_id, created_at: @created_at_gteq.to_date.beginning_of_day..@created_at_lteq.to_date.end_of_day).group(:title).sum(:total_cost_price)
        @products_sale_total =  OrderItem.joins(:product).where(product_id:product_id, created_at: @created_at_gteq.to_date.beginning_of_day..@created_at_lteq.to_date.end_of_day).sum(:total_cost_price)
        @products_count = OrderItem.joins(:product).where(product_id:product_id, created_at: @created_at_gteq.to_date.beginning_of_day..@created_at_lteq.to_date.end_of_day,transaction_type: "Purchase").group(:title).sum(:quantity)
      end

    else
      if params[:purchase_sale_details].present?
        params[:sale].present? ? @q = Order.where(:transaction_type=>"Sale").ransack(params[:q]) : @q = Order.where(:transaction_type=>"Purchase").ransack(params[:q])
      else
        if params[:sale].present?
          @q = Order.where(:transaction_type=>"Sale").ransack(params[:q])
        else
          @q = Order.where(:transaction_type=>"Purchase").ransack(params[:q])
        end
        @accounts=Account.all
      end
      if @q.result.count > 0
        @q.sorts = 'id desc' if @q.sorts.empty?
      end
      if params[:q].present?
      end
      @orders = @q.result.page(params[:page])
      @suppliers=SysUser.where(:user_group=>['Supplier','Both', 'Own'])
      @customers=SysUser.where(:user_group=>['Customer','Supplier','Both','Salesman'])
    end
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
    @products=Product.all
    @created_at_gteq = DateTime.current.beginning_of_month
    @created_at_lteq = DateTime.now
    if params[:q].present?
      @created_at_gteq = params[:q][:created_at_gteq] if params[:q][:created_at_gteq].present?
      @created_at_lteq = params[:q][:created_at_lteq] if params[:q][:created_at_lteq].present?
      params[:q][:created_at_lteq] = params[:q][:created_at_lteq].to_date.end_of_day if params[:q][:created_at_lteq].present?
    end
    if params[:purchase_submit].present? or params[:sale_submit].present?

      product_id= params[:q][:purchase_sale_items_product_product_id].present? ? params[:q][:purchase_sale_items_product_product_id] : @products
      if params[:sale_submit].present?
        @products_sale =  OrderItem.joins(:product).where(product_id:product_id, created_at: @created_at_gteq.to_date.beginning_of_day..@created_at_lteq.to_date.end_of_day).group(:title).sum(:total_sale_price)
        @products_sale_total =  OrderItem.joins(:product).where(product_id:product_id, created_at: @created_at_gteq.to_date.beginning_of_day..@created_at_lteq.to_date.end_of_day).sum(:total_sale_price)
        @products_count = OrderItem.joins(:product).where(product_id:product_id, created_at: @created_at_gteq.to_date.beginning_of_day..@created_at_lteq.to_date.end_of_day,transaction_type: "Sale").group(:title).sum(:quantity)
      else
        @products_sale =  OrderItem.joins(:product).where(product_id:product_id, created_at: @created_at_gteq.to_date.beginning_of_day..@created_at_lteq.to_date.end_of_day).group(:title).sum(:total_cost_price)
        @products_sale_total =  OrderItem.joins(:product).where(product_id:product_id, created_at: @created_at_gteq.to_date.beginning_of_day..@created_at_lteq.to_date.end_of_day).sum(:total_cost_price)
        @products_count = OrderItem.joins(:product).where(product_id:product_id, created_at: @created_at_gteq.to_date.beginning_of_day..@created_at_lteq.to_date.end_of_day,transaction_type: "Purchase").group(:title).sum(:quantity)
      end

    else
      if params[:purchase_sale_details].present?
        params[:sale].present? ? @q = Order.where(:transaction_type=>"Sale").ransack(params[:q]) : @q = Order.where(:transaction_type=>"Purchase").ransack(params[:q])
      else
        if params[:sale].present?
          @q = Order.where(:transaction_type=>"Sale").ransack(params[:q])
        else
          @q = Order.where(:transaction_type=>"Purchase").ransack(params[:q])
        end
        @accounts=Account.all
      end
      if @q.result.count > 0
        @q.sorts = 'id desc' if @q.sorts.empty?
      end
      if params[:q].present?
      end
      @orders = @q.result.page(params[:page])
      @suppliers=SysUser.where(:user_group=>['Supplier','Both', 'Own'])
      @customers=SysUser.where(:user_group=>['Customer','Supplier','Both','Salesman'])
    end
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
    redirect_to orders_path(sale: :true)
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
    @order.property_plans.build

    @suppliers=SysUser.where(:user_group=>['Supplier','Both','Own'])
    @customers=SysUser.where(:user_group=>['Customer','Both','Salesman'])
    @items=Item.all
    @products=Product.all
    @accounts=Account.all
    @account=current_user.user_account
  end

  # GET /orders/1/edit
  def edit
    @suppliers=SysUser.where(:user_group=>['Supplier','Both','Own'])
    @items=Item.all
    @item_types = ItemType.all
    @customers=SysUser.where(:user_group=>['Customer','Both','Salesman'])
    @products=Product.all
    @accounts=Account.all
    @order.order_items.build if @pos_setting.sys_type=="FastFood"
  end

  def transfer
    @suppliers=SysUser.where(:user_group=>['Supplier','Both','Own'])
    @items=Item.all
    @item_types = ItemType.all
    @customers=SysUser.where(:user_group=>['Customer','Both','Salesman'])
    @products=Product.all
    @accounts=Account.all
    @order.remarks.build

    @sys_user = @order.sys_user
    @user_types=UserType.all
    @cities=City.all
    @countries=Country.all

  end

  # POST /orders
  # POST /orders.json
  def create
    @order = Order.new(order_params)
    @pos_setting=PosSetting.first
    ledgerbook=LedgerBook.where(sys_user_id: order_params[:sys_user_id]).present? ? LedgerBook.where(sys_user_id: order_params[:sys_user_id]).last.balance : 0
    balance=ledgerbook
    @sysuser=SysUser.find(order_params[:sys_user_id]).present? ? SysUser.find(order_params[:sys_user_id]) : SysUser.first
    if balance==0
      sysuser=@sysuser.present? ? @sysuser.opening_balance : 0
      balance=sysuser
    end
    bill=order_params[:total_bill].to_i-order_params[:discount_price].to_i
    # if @sysuser.user_group=="Both" && order_params[:transaction_type]=="Sale"
      fullbalance=order_params[:amount].to_i+(balance.to_i)
    # else
      # fullbalance=(balance.to_i)-order_params[:amount].to_i
    # end
    @time = Time.zone.now
    Order.maximum(:id).present? ? psd=Order.maximum(:id).next : psd=1
    @order = Order.new(order_params)
    @id=Order.where(created_at: Time.zone.now.beginning_of_day..Time.zone.now.end_of_day).count+1
    @order.voucher_id=@id

    respond_to do |format|
      if @order.save!
        PaymentBalanceJob.perform_later(current_user.superAdmin.company_type, @order&.account&.id)
        if params[:commit]=="Save with Print"
          if @pos_setting.sys_type=="FastFood"
            format.html {render :partial => "/orders/fast_food/create"}
          elsif @pos_setting.sys_type!="MobileShop"
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
          if user_type(@sysuser.id)!='Supplier'
            @ledger_book = LedgerBook.new(sys_user_id: @sysuser.id,debit:0,credit:order_params[:amount].to_i,balance:fullbalance,comment:"Booking #"+psd.to_s+"  ||  "+(order_params["created_at(3i)"])+"/"+(order_params["created_at(2i)"])+"/"+(order_params["created_at(1i)"])+" "+@time.strftime("at %I:%M%p"),order_id: @order.id)
            @ledger_book.save!
          else
            @ledger_book = LedgerBook.new(sys_user_id: @sysuser.id,debit:order_params[:amount].to_i,credit:0,balance:fullbalance,comment:"Booking #"+psd.to_s+"  ||  "+(order_params["created_at(3i)"])+"/"+(order_params["created_at(2i)"])+"/"+(order_params["created_at(1i)"])+" "+@time.strftime("at %I:%M%p"),order_id: @order.id)
            @ledger_book.save!
          end
          format.html { redirect_to new_order_path(transaction_type: :sale,product: true), notice: 'Sale Order was successfully created.' }
        else
          @ledger_book = LedgerBook.new(sys_user_id: @sysuser.id,debit:0,credit:order_params[:amount].to_i,balance:fullbalance,comment:"Booking #"+psd.to_s+"  ||  "+(order_params["created_at(3i)"])+"/"+(order_params["created_at(2i)"])+"/"+(order_params["created_at(1i)"])+" "+@time.strftime("at %I:%M%p"),order_id: @order.id,account_id: @order.account_id)
          @ledger_book.save!
          format.html { redirect_to orders_path, notice: 'Purchase Order was successfully created.' }
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

  # PATCH/PUT /orders/1
  # PATCH/PUT /orders/1.json
  def update
    @pos_setting=PosSetting.first
    if params[:commit]=="Transfer"
      order_params[:remarks_attributes].each do |a|
        @order.sys_user.update(name:a.last[:body]) if a.last[:body].present?
      end

      # order.sys_user.name=
    end
    respond_to do |format|
      if @order.update!(order_params)
        @order.update(status: 'UnPrint')
        if params[:commit]=="Save with Print"
          if @pos_setting.sys_type=="FastFood"
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

        if @order.transaction_type=='Sale'
          if @pos_setting.sys_type=="FastFood"
            format.html { redirect_to biller_orders_path(sale: :true), notice: 'Sale order detail was successfully updated.' }
          else
            format.html { redirect_to orders_path(sale: :true), notice: 'Sale order detail was successfully updated.' }
          end
          if @pos_setting.sms_templates.present?
            send_sms(@order.sys_user&.contact&.phone_with_comma,@pos_setting.sms_templates["update_order"],'','') if @pos_setting.sms_templates["update_order"].present?
          end
        else
          format.html { redirect_to orders_path, notice: 'Purchase order detail was successfully updated.' }
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
    type=@order.transaction_type
    # @order.order_items.destroy_all if @order.order_items.present?
    # @order.payment.destroy_all if @order.payment.present?
    # @order.ledger_book.destroy if @order.ledger_book.present?
    @order.destroy
    UserLedgerBookJob.perform_later(current_user.superAdmin.company_type,@order.sys_user_id)
    AccountPaymentJob.perform_later(current_user.superAdmin.company_type,@order.account_id)
    if type=="Purchase"
      respond_to do |format|
        format.html { redirect_to orders_path, notice: 'Purchase Order detail was successfully destroyed.' }
        format.json { head :no_content }
        format.js   { render :layout => false }

      end
    else
      respond_to do |format|
        format.html { redirect_to orders_path(sale: :true), notice: 'Purchase Order detail was successfully destroyed.' }
        format.json { head :no_content }
        format.js   { render :layout => false }

      end
    end
  end
  def user_type(id)
    SysUser.find(id).user_group
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
    @q = PaperTrail::Version.where(item_type:"Order").order('created_at desc').ransack(params[:q])
    @order_logs = @q.result.page(params[:page])
    respond_to do |format|
      format.js
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
