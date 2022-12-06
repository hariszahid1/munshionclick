class PurchaseSaleDetailsController < ApplicationController
  before_action :set_purchase_sale_detail, only: [:show, :edit, :update, :destroy]

  # GET /purchase_sale_details
  # GET /purchase_sale_details.json
  def index
    @users=PurchaseSaleDetail.pluck(:user_name).uniq
    @pos_type_batha=pos_type_batha
    @products=Product.all
    @items=Item.all
    @created_at_gteq = DateTime.now-2000
    @created_at_lteq = DateTime.now
    if params[:q].present?
      @created_at_gteq = params[:q][:created_at_gteq] if params[:q][:created_at_gteq].present?
      @created_at_lteq = params[:q][:created_at_lteq] if params[:q][:created_at_lteq].present?
      params[:q][:created_at_lteq] = params[:q][:created_at_lteq].to_date.end_of_day if params[:q][:created_at_lteq].present?
      @title = params[:q][:purchase_sale_items_product_id_eq]
      @item_title = params[:q][:purchase_sale_items_item_id_eq]
      @name = params[:q][:sys_user_id_eq]
      @staff = params[:q][:staff_id_eq]
    end
    @transaction_type_logs = params[:sale].present? ? 'Sale' : 'Purchase'

    @orders=Order.all
    if params[:purchase_sale_details].present?
      if params[:sale].present?
        @q = PurchaseSaleDetail.includes(:purchase_sale_items).joins(:purchase_sale_items).where(:transaction_type=>"Sale").ransack(params[:q])
        @k = PurchaseSaleDetail.includes(:purchase_sale_items).joins(:purchase_sale_items).where(:transaction_type=>"Sale").ransack(params[:q])
      elsif params[:return].present?
        @q = PurchaseSaleDetail.includes(:purchase_sale_items).joins(:purchase_sale_items).where(:transaction_type=>"SaleReturn").ransack(params[:q])
        @k = PurchaseSaleDetail.includes(:purchase_sale_items).joins(:purchase_sale_items).where(:transaction_type=>"SaleReturn").ransack(params[:q])
      else
        @q = PurchaseSaleDetail.includes(:purchase_sale_items).joins(:purchase_sale_items).where(:transaction_type=>"Purchase").ransack(params[:q])
        @k = PurchaseSaleDetail.includes(:purchase_sale_items).joins(:purchase_sale_items).where(:transaction_type=>"Purchase").ransack(params[:q])
      end
    else
      if params[:sale].present?
        @q = PurchaseSaleDetail.includes(:purchase_sale_items).joins(:purchase_sale_items).where(:transaction_type=>"Sale").ransack(params[:q])
        @k = PurchaseSaleDetail.includes(:purchase_sale_items).joins(:purchase_sale_items).where(:transaction_type=>"Sale").ransack(params[:q])
      elsif params[:return].present?
        @q = PurchaseSaleDetail.includes(:purchase_sale_items).joins(:purchase_sale_items).where(:transaction_type=>"SaleReturn").ransack(params[:q])
        @k = PurchaseSaleDetail.includes(:purchase_sale_items).joins(:purchase_sale_items).where(:transaction_type=>"SaleReturn").ransack(params[:q])
      else
        @q = PurchaseSaleDetail.includes(:purchase_sale_items).joins(:purchase_sale_items).where(:transaction_type=>"Purchase").ransack(params[:q])
        @k = PurchaseSaleDetail.includes(:purchase_sale_items).joins(:purchase_sale_items).where(:transaction_type=>"Purchase").ransack(params[:q])
      end
      @accounts=Account.all
    end
      if @q.result.count > 0
        @q.sorts = 'id desc' if @q.sorts.empty?
      end
      purchase_sale_detail = @q.result
      purchase_sale_detail_k = @k.result.distinct("purchase_sale_details.id").pluck(:id)
      @purchase_sale_details = purchase_sale_detail.page(params[:page]).per(100)
      @suppliers=SysUser.where(:user_group=>['Supplier','Both', 'Own'])
      @customers=SysUser.where(:user_group=>['Customer','Supplier','Both','Salesman'])
      @staffs=Staff.loader_active_staff
      @staffs=Staff.all if pos_setting_sys_type=="HousingScheme"
      @total_bil = PurchaseSaleDetail.where(id: purchase_sale_detail_k).sum(:total_bill)
      @total_am = PurchaseSaleDetail.where(id: purchase_sale_detail_k).sum(:amount)
      @total_dis=PurchaseSaleDetail.where(id: purchase_sale_detail_k).sum(:discount_price)
      @total_profit= PurchaseSaleItem.where(purchase_sale_detail_id: purchase_sale_detail ).sum('total_sale_price-total_cost_price')

      if params[:purchase_submit].present? or params[:sale_submit].present?
        product_id= params[:q][:purchase_sale_items_product_product_id].present? ? params[:q][:purchase_sale_items_product_product_id] : @products
        @sys_users = SysUser.all
        sys_user_id = params[:q][:sys_user_id_eq].present? ? params[:q][:sys_user_id_eq] : @sys_users
        staff =  params[:q][:staff_id_eq] if params[:q][:staff_id_eq].present?
        user_name =  params[:q][:user_name_eq] if params[:q][:user_name_eq].present?
        if params[:sale_submit].present?
          # @products_sale =  PurchaseSaleItem.joins(:product).where(product_id:product_id, created_at: @created_at_gteq.to_date.beginning_of_day..@created_at_lteq.to_date.end_of_day).group(:title).sum(:total_sale_price)
          # @products_sale_total =  PurchaseSaleItem.joins(:product).where(product_id:product_id, created_at: @created_at_gteq.to_date.beginning_of_day..@created_at_lteq.to_date.end_of_day).sum(:total_sale_price)
          # @products_count = PurchaseSaleItem.joins(:product).where(product_id:product_id, created_at: @created_at_gteq.to_date.beginning_of_day..@created_at_lteq.to_date.end_of_day,transaction_type: "Sale").group(:title).sum('purchase_sale_items.quantity')
          if staff
            if user_name
              @products_sale_price = PurchaseSaleDetail.joins(purchase_sale_items: :product).where(transaction_type: "Sale").where('purchase_sale_items.product_id':product_id).where(sys_user_id: sys_user_id,  'purchase_sale_items.created_at': @created_at_gteq.to_date.beginning_of_day..@created_at_lteq.to_date.end_of_day,transaction_type: "Sale",staff_id: staff, user_name: user_name).group(:title).average('purchase_sale_items.sale_price')
              @products_sale = PurchaseSaleDetail.joins(purchase_sale_items: :product).where(transaction_type: "Sale").where('purchase_sale_items.product_id':product_id).where(sys_user_id: sys_user_id,  'purchase_sale_items.created_at': @created_at_gteq.to_date.beginning_of_day..@created_at_lteq.to_date.end_of_day,transaction_type: "Sale",staff_id: staff, user_name: user_name).group(:title).sum(:total_sale_price)
              @products_sale_count = PurchaseSaleDetail.joins(purchase_sale_items: :product).where(transaction_type: "Sale").where('purchase_sale_items.product_id':product_id).where(sys_user_id: sys_user_id, 'purchase_sale_items.created_at': @created_at_gteq.to_date.beginning_of_day..@created_at_lteq.to_date.end_of_day,transaction_type: "Sale",staff_id: staff, user_name: user_name).group(:title).sum('purchase_sale_items.quantity')
              @products_sale_total = PurchaseSaleDetail.joins(purchase_sale_items: :product).where(transaction_type: "Sale").where('purchase_sale_items.product_id':product_id).where(sys_user_id: sys_user_id, 'purchase_sale_items.created_at': @created_at_gteq.to_date.beginning_of_day..@created_at_lteq.to_date.end_of_day,transaction_type: "Sale",staff_id: staff, user_name: user_name).sum(:total_sale_price)
            else
              @products_sale_price = PurchaseSaleDetail.joins(purchase_sale_items: :product).where(transaction_type: "Sale").where('purchase_sale_items.product_id':product_id).where(sys_user_id: sys_user_id,  'purchase_sale_items.created_at': @created_at_gteq.to_date.beginning_of_day..@created_at_lteq.to_date.end_of_day,transaction_type: "Sale",staff_id: staff).group(:title).average(:sale_price)
              @products_sale = PurchaseSaleDetail.joins(purchase_sale_items: :product).where(transaction_type: "Sale").where('purchase_sale_items.product_id':product_id).where(sys_user_id: sys_user_id,  'purchase_sale_items.created_at': @created_at_gteq.to_date.beginning_of_day..@created_at_lteq.to_date.end_of_day,transaction_type: "Sale",staff_id: staff).group(:title).sum(:total_sale_price)
              @products_count = PurchaseSaleDetail.joins(purchase_sale_items: :product).where(transaction_type: "Sale").where('purchase_sale_items.product_id':product_id).where(sys_user_id: sys_user_id, 'purchase_sale_items.created_at': @created_at_gteq.to_date.beginning_of_day..@created_at_lteq.to_date.end_of_day,transaction_type: "Sale",staff_id: staff).group(:title).sum('purchase_sale_items.quantity')
              @products_sale_total = PurchaseSaleDetail.joins(purchase_sale_items: :product).where(transaction_type: "Sale").where('purchase_sale_items.product_id':product_id).where(sys_user_id: sys_user_id, 'purchase_sale_items.created_at': @created_at_gteq.to_date.beginning_of_day..@created_at_lteq.to_date.end_of_day,transaction_type: "Sale",staff_id: staff).sum(:total_sale_price)
            end
          else
            if user_name
              @products_sale_price = PurchaseSaleDetail.joins(purchase_sale_items: :product).where(transaction_type: "Sale").where('purchase_sale_items.product_id':product_id).where(sys_user_id: sys_user_id,  'purchase_sale_items.created_at': @created_at_gteq.to_date.beginning_of_day..@created_at_lteq.to_date.end_of_day,transaction_type: "Sale", user_name: user_name).group(:title).average('purchase_sale_items.sale_price')
              @products_sale = PurchaseSaleDetail.joins(purchase_sale_items: :product).where(transaction_type: "Sale").where('purchase_sale_items.product_id':product_id).where(sys_user_id: sys_user_id,  'purchase_sale_items.created_at': @created_at_gteq.to_date.beginning_of_day..@created_at_lteq.to_date.end_of_day,transaction_type: "Sale", user_name: user_name).group(:title).sum(:total_sale_price)
              @products_count = PurchaseSaleDetail.joins(purchase_sale_items: :product).where(transaction_type: "Sale").where('purchase_sale_items.product_id':product_id).where(sys_user_id: sys_user_id, 'purchase_sale_items.created_at': @created_at_gteq.to_date.beginning_of_day..@created_at_lteq.to_date.end_of_day,transaction_type: "Sale", user_name: user_name).group(:title).sum('purchase_sale_items.quantity')
              @products_sale_total = PurchaseSaleDetail.joins(purchase_sale_items: :product).where(transaction_type: "Sale").where('purchase_sale_items.product_id':product_id).where(sys_user_id: sys_user_id, 'purchase_sale_items.created_at': @created_at_gteq.to_date.beginning_of_day..@created_at_lteq.to_date.end_of_day,transaction_type: "Sale", user_name: user_name).sum(:total_sale_price)
            else
              @products_sale_price = PurchaseSaleDetail.joins(purchase_sale_items: :product).where(transaction_type: "Sale").where('purchase_sale_items.product_id':product_id).where(sys_user_id: sys_user_id,  'purchase_sale_items.created_at': @created_at_gteq.to_date.beginning_of_day..@created_at_lteq.to_date.end_of_day,transaction_type: "Sale").group(:title).average('purchase_sale_items.sale_price')
              @products_sale = PurchaseSaleDetail.joins(purchase_sale_items: :product).where(transaction_type: "Sale").where('purchase_sale_items.product_id':product_id).where(sys_user_id: sys_user_id,  'purchase_sale_items.created_at': @created_at_gteq.to_date.beginning_of_day..@created_at_lteq.to_date.end_of_day,transaction_type: "Sale").group(:title).sum(:total_sale_price)
              @products_count = PurchaseSaleDetail.joins(purchase_sale_items: :product).where(transaction_type: "Sale").where('purchase_sale_items.product_id':product_id).where(sys_user_id: sys_user_id, 'purchase_sale_items.created_at': @created_at_gteq.to_date.beginning_of_day..@created_at_lteq.to_date.end_of_day,transaction_type: "Sale").group(:title).sum('purchase_sale_items.quantity')
              @products_sale_total = PurchaseSaleDetail.joins(purchase_sale_items: :product).where(transaction_type: "Sale").where('purchase_sale_items.product_id':product_id).where(sys_user_id: sys_user_id, 'purchase_sale_items.created_at': @created_at_gteq.to_date.beginning_of_day..@created_at_lteq.to_date.end_of_day,transaction_type: "Sale").sum(:total_sale_price)
            end
          end
          if user_name
            @product_carriage = PurchaseSaleDetail.joins(purchase_sale_items: :product).where(sys_user_id: sys_user_id,'purchase_sale_items.created_at': @created_at_gteq.to_date.beginning_of_day..@created_at_lteq.to_date.end_of_day,transaction_type: "Sale",staff_id: staff, user_name: user_name).sum(:carriage)
            @product_loading = PurchaseSaleDetail.joins(purchase_sale_items: :product).where(sys_user_id: sys_user_id,'purchase_sale_items.created_at': @created_at_gteq.to_date.beginning_of_day..@created_at_lteq.to_date.end_of_day,transaction_type: "Sale",staff_id: staff, user_name: user_name).sum(:loading)
          else
            @product_carriage = PurchaseSaleDetail.joins(purchase_sale_items: :product).where(sys_user_id: sys_user_id,'purchase_sale_items.created_at': @created_at_gteq.to_date.beginning_of_day..@created_at_lteq.to_date.end_of_day,transaction_type: "Sale",staff_id: staff).sum(:carriage)
            @product_loading = PurchaseSaleDetail.joins(purchase_sale_items: :product).where(sys_user_id: sys_user_id,'purchase_sale_items.created_at': @created_at_gteq.to_date.beginning_of_day..@created_at_lteq.to_date.end_of_day,transaction_type: "Sale",staff_id: staff).sum(:loading)
          end

        else
          # @products_sale =  PurchaseSaleItem.joins(:product).where(product_id:product_id, created_at: @created_at_gteq.to_date.beginning_of_day..@created_at_lteq.to_date.end_of_day).group(:title).sum(:total_cost_price)0
          # @products_sale_total =  PurchaseSaleItem.joins(:product).where(product_id:product_id, created_at: @created_at_gteq.to_date.beginning_of_day..@created_at_lteq.to_date.end_of_day).sum(:total_cost_price)
          # @products_count = PurchaseSaleItem.joins(:product).where(product_id:product_id, created_at: @created_at_gteq.to_date.beginning_of_day..@created_at_lteq.to_date.end_of_day,transaction_type: "Purchase").group(:title).sum('purchase_sale_items.quantity')
          if user_name
            @products_sale_price = PurchaseSaleDetail.joins(purchase_sale_items: :product).where('purchase_sale_items.product_id':product_id).where(sys_user_id: sys_user_id, created_at: @created_at_gteq.to_date.beginning_of_day..@created_at_lteq.to_date.end_of_day,transaction_type: "Purchase",staff_id: staff, user_name: user_name).group(:title).average(:cost_price)
            @products_sale = PurchaseSaleDetail.joins(purchase_sale_items: :product).where('purchase_sale_items.product_id':product_id).where(sys_user_id: sys_user_id, created_at: @created_at_gteq.to_date.beginning_of_day..@created_at_lteq.to_date.end_of_day,transaction_type: "Purchase",staff_id: staff, user_name: user_name).group(:title).sum(:total_cost_price)
            @products_count = PurchaseSaleDetail.joins(purchase_sale_items: :product).where('purchase_sale_items.product_id':product_id).where(sys_user_id: sys_user_id, created_at: @created_at_gteq.to_date.beginning_of_day..@created_at_lteq.to_date.end_of_day,transaction_type: "Purchase",staff_id: staff, user_name: user_name).group(:title).sum('purchase_sale_items.quantity')
            @products_sale_total = PurchaseSaleDetail.joins(purchase_sale_items: :product).where('purchase_sale_items.product_id':product_id).where(sys_user_id: sys_user_id, created_at: @created_at_gteq.to_date.beginning_of_day..@created_at_lteq.to_date.end_of_day,transaction_type: "Purchase",staff_id: staff, user_name: user_name).sum(:total_cost_price)
            @product_carriage = PurchaseSaleDetail.where(sys_user_id: sys_user_id,created_at: @created_at_gteq.to_date.beginning_of_day..@created_at_lteq.to_date.end_of_day,transaction_type: "Purchase",staff_id: staff, user_name: user_name).sum(:carriage)
            @product_loading = PurchaseSaleDetail.where(sys_user_id: sys_user_id,created_at: @created_at_gteq.to_date.beginning_of_day..@created_at_lteq.to_date.end_of_day,transaction_type: "Purchase",staff_id: staff, user_name: user_name).sum(:loading)
          else
            @products_sale_price = PurchaseSaleDetail.joins(purchase_sale_items: :product).where('purchase_sale_items.product_id':product_id).where(sys_user_id: sys_user_id, created_at: @created_at_gteq.to_date.beginning_of_day..@created_at_lteq.to_date.end_of_day,transaction_type: "Purchase",staff_id: staff).group(:title).average(:cost_price)
            @products_sale = PurchaseSaleDetail.joins(purchase_sale_items: :product).where('purchase_sale_items.product_id':product_id).where(sys_user_id: sys_user_id, created_at: @created_at_gteq.to_date.beginning_of_day..@created_at_lteq.to_date.end_of_day,transaction_type: "Purchase",staff_id: staff).group(:title).sum(:total_cost_price)
            @products_count = PurchaseSaleDetail.joins(purchase_sale_items: :product).where('purchase_sale_items.product_id':product_id).where(sys_user_id: sys_user_id, created_at: @created_at_gteq.to_date.beginning_of_day..@created_at_lteq.to_date.end_of_day,transaction_type: "Purchase",staff_id: staff).group(:title).sum('purchase_sale_items.quantity')
            @products_sale_total = PurchaseSaleDetail.joins(purchase_sale_items: :product).where('purchase_sale_items.product_id':product_id).where(sys_user_id: sys_user_id, created_at: @created_at_gteq.to_date.beginning_of_day..@created_at_lteq.to_date.end_of_day,transaction_type: "Purchase",staff_id: staff).sum(:total_cost_price)
            @product_carriage = PurchaseSaleDetail.where(sys_user_id: sys_user_id,created_at: @created_at_gteq.to_date.beginning_of_day..@created_at_lteq.to_date.end_of_day,transaction_type: "Purchase",staff_id: staff).sum(:carriage)
            @product_loading = PurchaseSaleDetail.where(sys_user_id: sys_user_id,created_at: @created_at_gteq.to_date.beginning_of_day..@created_at_lteq.to_date.end_of_day,transaction_type: "Purchase",staff_id: staff).sum(:loading)
          end
        end
        if params[:purchase_submit] == "Total Purchase PDF A4" or params[:sale_submit] == "Total Sale PDF A4"
          respond_to do |format|
            request.format = 'pdf'
            format.html
            format.pdf do
              @pos_setting=PosSetting.first
              render pdf: '['+(PurchaseSaleDetail.where(id:@purchase_sale_details.ids).joins(:sys_user).pluck('name').uniq.join(' '))+']'+@created_at_gteq.to_s+'-'+@created_at_lteq.to_s,
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
        else
          respond_to do |format|
            request.format = 'pdf'
            format.html
            format.pdf do
              @pos_setting=PosSetting.first
              render pdf: '['+(PurchaseSaleDetail.where(id:@purchase_sale_details.ids).joins(:sys_user).pluck('name').uniq.join(' '))+']'+@created_at_gteq.to_s+'-'+@created_at_lteq.to_s,
              layout: 'pdf.html',
              page_size: 'A8',
              margin_top: '0',
              margin_right: '0',
              margin_bottom: '0',
              margin_left: '0',
              encoding: "UTF-8",
              show_as_html: true
            end
          end
        end
      end
      if params[:submit_pdf_staff_without].present? or params[:submit_pdf_staff_without_bulk].present? or params[:email].present?
        product_id= params[:q][:purchase_sale_items_product_product_id].present? ? params[:q][:purchase_sale_items_product_product_id] : @products
        @sys_users = SysUser.all
        sys_user_id = params[:q][:sys_user_id_eq].present? ? params[:q][:sys_user_id_eq] : @sys_users
        user_name =  params[:q][:user_name_eq] if params[:q][:user_name_eq].present?
        if params[:submit_pdf_staff_without].present? or params[:email].present? or params[:submit_pdf_staff_without_bulk].present?
          if staff
            if user_name
              @products_sale_price =  PurchaseSaleItem.joins(:purchase_sale_detail,:product).where(product_id:product_id, created_at: @created_at_gteq.to_date.beginning_of_day..@created_at_lteq.to_date.end_of_day,transaction_type: "Sale",'purchase_sale_details.staff_id': staff, 'purchase_sale_details.user_name': user_name).group(:title).average(:sale_price)
              @products_sale =  PurchaseSaleItem.joins(:purchase_sale_detail,:product).where(product_id:product_id, created_at: @created_at_gteq.to_date.beginning_of_day..@created_at_lteq.to_date.end_of_day,transaction_type: "Sale",'purchase_sale_details.staff_id': staff, 'purchase_sale_details.user_name': user_name).group(:title).sum(:total_sale_price)
              @products_count = PurchaseSaleItem.joins(:purchase_sale_detail,:product).where(product_id:product_id, created_at: @created_at_gteq.to_date.beginning_of_day..@created_at_lteq.to_date.end_of_day,transaction_type: "Sale",'purchase_sale_details.staff_id': staff, 'purchase_sale_details.user_name': user_name).group(:title).sum('purchase_sale_items.quantity')
              @products_group = PurchaseSaleDetail.joins(purchase_sale_items: :product).where(sys_user_id: sys_user_id, created_at: @created_at_gteq.to_date.beginning_of_day..@created_at_lteq.to_date.end_of_day,transaction_type: "Sale",staff_id: staff, user_name: user_name).group(:title).sum('purchase_sale_items.quantity')
              @products_group_count = PurchaseSaleDetail.joins(purchase_sale_items: :product).where(sys_user_id: sys_user_id, created_at: @created_at_gteq.to_date.beginning_of_day..@created_at_lteq.to_date.end_of_day,transaction_type: "Sale",staff_id: staff, user_name: user_name).sum('purchase_sale_items.quantity')
            else
              @products_sale_price =  PurchaseSaleItem.joins(:purchase_sale_detail,:product).where(product_id:product_id, created_at: @created_at_gteq.to_date.beginning_of_day..@created_at_lteq.to_date.end_of_day,transaction_type: "Sale",'purchase_sale_details.staff_id': staff).group(:title).average(:sale_price)
              @products_sale =  PurchaseSaleItem.joins(:purchase_sale_detail,:product).where(product_id:product_id, created_at: @created_at_gteq.to_date.beginning_of_day..@created_at_lteq.to_date.end_of_day,transaction_type: "Sale",'purchase_sale_details.staff_id': staff).group(:title).sum(:total_sale_price)
              @products_count = PurchaseSaleItem.joins(:purchase_sale_detail,:product).where(product_id:product_id, created_at: @created_at_gteq.to_date.beginning_of_day..@created_at_lteq.to_date.end_of_day,transaction_type: "Sale",'purchase_sale_details.staff_id': staff).group(:title).sum('purchase_sale_items.quantity')
              @products_group = PurchaseSaleDetail.joins(purchase_sale_items: :product).where(sys_user_id: sys_user_id, created_at: @created_at_gteq.to_date.beginning_of_day..@created_at_lteq.to_date.end_of_day,transaction_type: "Sale",staff_id: staff).group(:title).sum('purchase_sale_items.quantity')
              @products_group_count = PurchaseSaleDetail.joins(purchase_sale_items: :product).where(sys_user_id: sys_user_id, created_at: @created_at_gteq.to_date.beginning_of_day..@created_at_lteq.to_date.end_of_day,transaction_type: "Sale",staff_id: staff).sum('purchase_sale_items.quantity')
            end
          else
            if user_name
              @products_sale_price =  PurchaseSaleItem.joins(:purchase_sale_detail,:product).where(product_id:product_id, created_at: @created_at_gteq.to_date.beginning_of_day..@created_at_lteq.to_date.end_of_day,transaction_type: "Sale", 'purchase_sale_details.user_name': user_name).group(:title).average(:sale_price)
              @products_sale =  PurchaseSaleItem.joins(:purchase_sale_detail,:product).where(product_id:product_id, created_at: @created_at_gteq.to_date.beginning_of_day..@created_at_lteq.to_date.end_of_day,transaction_type: "Sale", 'purchase_sale_details.user_name': user_name).group(:title).sum(:total_sale_price)
              @products_count = PurchaseSaleItem.joins(:purchase_sale_detail,:product).where(product_id:product_id, created_at: @created_at_gteq.to_date.beginning_of_day..@created_at_lteq.to_date.end_of_day,transaction_type: "Sale", 'purchase_sale_details.user_name': user_name).group(:title).sum('purchase_sale_items.quantity')
              @products_group = PurchaseSaleDetail.joins(purchase_sale_items: :product).where(sys_user_id: sys_user_id, created_at: @created_at_gteq.to_date.beginning_of_day..@created_at_lteq.to_date.end_of_day,transaction_type: "Sale", user_name: user_name).group(:title).sum('purchase_sale_items.quantity')
              @products_group_count = PurchaseSaleDetail.joins(purchase_sale_items: :product).where(sys_user_id: sys_user_id, created_at: @created_at_gteq.to_date.beginning_of_day..@created_at_lteq.to_date.end_of_day,transaction_type: "Sale", user_name: user_name).sum('purchase_sale_items.quantity')
            else
              @products_sale_price =  PurchaseSaleItem.joins(:purchase_sale_detail,:product).where(product_id:product_id, created_at: @created_at_gteq.to_date.beginning_of_day..@created_at_lteq.to_date.end_of_day,transaction_type: "Sale").group(:title).average(:sale_price)
              @products_sale =  PurchaseSaleItem.joins(:purchase_sale_detail,:product).where(product_id:product_id, created_at: @created_at_gteq.to_date.beginning_of_day..@created_at_lteq.to_date.end_of_day,transaction_type: "Sale").group(:title).sum(:total_sale_price)
              @products_count = PurchaseSaleItem.joins(:purchase_sale_detail,:product).where(product_id:product_id, created_at: @created_at_gteq.to_date.beginning_of_day..@created_at_lteq.to_date.end_of_day,transaction_type: "Sale").group(:title).sum('purchase_sale_items.quantity')
              @products_group = PurchaseSaleDetail.joins(purchase_sale_items: :product).where(sys_user_id: sys_user_id, created_at: @created_at_gteq.to_date.beginning_of_day..@created_at_lteq.to_date.end_of_day,transaction_type: "Sale").group(:title).sum('purchase_sale_items.quantity')
              @products_group_count = PurchaseSaleDetail.joins(purchase_sale_items: :product).where(sys_user_id: sys_user_id, created_at: @created_at_gteq.to_date.beginning_of_day..@created_at_lteq.to_date.end_of_day,transaction_type: "Sale").sum('purchase_sale_items.quantity')
            end
          end
        else
          if staff
            if user_name
              @products_sale_price =  PurchaseSaleItem.joins(:product).where(product_id:product_id, created_at: @created_at_gteq.to_date.beginning_of_day..@created_at_lteq.to_date.end_of_day,'purchase_sale_details.staff_id': staff).group(:title).average(:cost_price)
              @products_sale =  PurchaseSaleItem.joins(:product).where(product_id:product_id, created_at: @created_at_gteq.to_date.beginning_of_day..@created_at_lteq.to_date.end_of_day,'purchase_sale_details.staff_id': staff).group(:title).sum(:total_cost_price)
              @products_sale_total =  PurchaseSaleItem.joins(:product).where(product_id:product_id, created_at: @created_at_gteq.to_date.beginning_of_day..@created_at_lteq.to_date.end_of_day,'purchase_sale_details.staff_id': staff).sum(:total_cost_price)
              @products_count = PurchaseSaleItem.joins(:product).where(product_id:product_id, created_at: @created_at_gteq.to_date.beginning_of_day..@created_at_lteq.to_date.end_of_day,transaction_type: "Purchase",'purchase_sale_details.staff_id': staff).group(:title).sum('purchase_sale_items.quantity')
            else
              @products_sale_price =  PurchaseSaleItem.joins(:product).where(product_id:product_id, created_at: @created_at_gteq.to_date.beginning_of_day..@created_at_lteq.to_date.end_of_day,'purchase_sale_details.staff_id': staff).group(:title).average(:cost_price)
              @products_sale =  PurchaseSaleItem.joins(:product).where(product_id:product_id, created_at: @created_at_gteq.to_date.beginning_of_day..@created_at_lteq.to_date.end_of_day,'purchase_sale_details.staff_id': staff).group(:title).sum(:total_cost_price)
              @products_sale_total =  PurchaseSaleItem.joins(:product).where(product_id:product_id, created_at: @created_at_gteq.to_date.beginning_of_day..@created_at_lteq.to_date.end_of_day,'purchase_sale_details.staff_id': staff).sum(:total_cost_price)
              @products_count = PurchaseSaleItem.joins(:product).where(product_id:product_id, created_at: @created_at_gteq.to_date.beginning_of_day..@created_at_lteq.to_date.end_of_day,transaction_type: "Purchase",'purchase_sale_details.staff_id': staff).group(:title).sum('purchase_sale_items.quantity')
            end
          else
            if user_name
              @products_sale_price =  PurchaseSaleItem.joins(:product).where(product_id:product_id, created_at: @created_at_gteq.to_date.beginning_of_day..@created_at_lteq.to_date.end_of_day).group(:title).average(:cost_price)
              @products_sale =  PurchaseSaleItem.joins(:product).where(product_id:product_id, created_at: @created_at_gteq.to_date.beginning_of_day..@created_at_lteq.to_date.end_of_day).group(:title).sum(:total_cost_price)
              @products_sale_total =  PurchaseSaleItem.joins(:product).where(product_id:product_id, created_at: @created_at_gteq.to_date.beginning_of_day..@created_at_lteq.to_date.end_of_day).sum(:total_cost_price)
              @products_count = PurchaseSaleItem.joins(:product).where(product_id:product_id, created_at: @created_at_gteq.to_date.beginning_of_day..@created_at_lteq.to_date.end_of_day,transaction_type: "Purchase").group(:title).sum('purchase_sale_items.quantity')
            else
              @products_sale_price =  PurchaseSaleItem.joins(:product).where(product_id:product_id, created_at: @created_at_gteq.to_date.beginning_of_day..@created_at_lteq.to_date.end_of_day).group(:title).average(:cost_price)
              @products_sale =  PurchaseSaleItem.joins(:product).where(product_id:product_id, created_at: @created_at_gteq.to_date.beginning_of_day..@created_at_lteq.to_date.end_of_day).group(:title).sum(:total_cost_price)
              @products_sale_total =  PurchaseSaleItem.joins(:product).where(product_id:product_id, created_at: @created_at_gteq.to_date.beginning_of_day..@created_at_lteq.to_date.end_of_day).sum(:total_cost_price)
              @products_count = PurchaseSaleItem.joins(:product).where(product_id:product_id, created_at: @created_at_gteq.to_date.beginning_of_day..@created_at_lteq.to_date.end_of_day,transaction_type: "Purchase").group(:title).sum('purchase_sale_items.quantity')
            end
          end
        end
        if params[:email].present?
          @pos_setting=PosSetting.first
          @purchase_sale_details_pdf = @q.result
          @pdf_sale=render_to_string(:pdf => "Sale Detail Full",:template => 'layouts/index_batha.pdf.erb',:filename => 'Sale Detail')
          @pdf_index=render_to_string(:pdf => "Sale Detail Short",:template => 'purchase_sale_details/index.pdf.erb',:filename => 'Totay Short Sale Detail')
        else
          if params[:submit_pdf_staff_without_bulk].present?
            respond_to do |format|
              request.format = 'pdf'
              format.html
              format.pdf do
                @pos_setting=PosSetting.first
                @purchase_sale_details_pdf = @q.result
                render pdf: '['+(PurchaseSaleDetail.where(id:@purchase_sale_details_pdf.ids).joins(:sys_user).pluck('name').uniq.join(' '))+']'+@created_at_gteq.to_s+'-'+@created_at_lteq.to_s,
                layout: 'invoice_bulk.pdf',
                page_size: 'A4',
                margin_top: '0',
                margin_right: '0',
                margin_bottom: '0',
                margin_left: '0',
                footer:  {             # optional, use 'pdf_plain' for a pdf_plain.html.pdf.erb file, defaults to main layout
                  right: '[page] of [topage]'},
                show_as_html: false
              end
            end
          else
            respond_to do |format|
              request.format = 'pdf'
              format.html
              format.pdf do
                @pos_setting=PosSetting.first
                @purchase_sale_details_pdf = @q.result
                render pdf: '['+(PurchaseSaleDetail.where(id:@purchase_sale_details_pdf.ids).joins(:sys_user).pluck('name').uniq.join(' '))+']'+@created_at_gteq.to_s+'-'+@created_at_lteq.to_s,
                layout: 'index_batha.pdf',
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

      end
      if params[:email].present?
        @pos_setting=PosSetting.first
        @purchase_sale_details_pdf = @q.result
        subject = "#{@pos_setting.display_name} - Sale Detail - From #{@created_at_gteq.to_date} To #{@created_at_lteq.to_date}"
        email = current_user.superAdmin.email_to.present? ? current_user.superAdmin.email_to : "info@munshionclick.com"
        pdf=[[@pdf_sale,'Sale_Detail'],[@pdf_index,"Sale"]]
        body=@products_sale
        ReportMailer.new_report_email(pdf,subject,email,"").deliver
        return redirect_to purchase_sale_details_path(sale: true)
      end
  end

  def purchase_sale_details_return
    @users=PurchaseSaleDetail.pluck(:user_name).uniq
    @pos_type_batha=pos_type_batha
    @products=Product.all
    @items=Item.all
    @created_at_gteq = DateTime.now-2000
    @created_at_lteq = DateTime.now
    if params[:q].present?
      @created_at_gteq = params[:q][:created_at_gteq] if params[:q][:created_at_gteq].present?
      @created_at_lteq = params[:q][:created_at_lteq] if params[:q][:created_at_lteq].present?
      params[:q][:created_at_lteq] = params[:q][:created_at_lteq].to_date.end_of_day if params[:q][:created_at_lteq].present?
      @title = params[:q][:purchase_sale_items_product_id_eq]
      @item_title = params[:q][:purchase_sale_items_item_id_eq]
      @name = params[:q][:sys_user_id_eq]
      @staff = params[:q][:staff_id_eq]
    end

    @orders=Order.all
    if params[:purchase_sale_details].present?
      @q = PurchaseSaleDetail.includes(:purchase_sale_items).joins(:purchase_sale_items).where(:transaction_type=>"SaleReturn").ransack(params[:q])
      @k = PurchaseSaleDetail.includes(:purchase_sale_items).joins(:purchase_sale_items).where(:transaction_type=>"SaleReturn").ransack(params[:q])
    else
      @q = PurchaseSaleDetail.includes(:purchase_sale_items).joins(:purchase_sale_items).where(:transaction_type=>"SaleReturn").ransack(params[:q])
      @k = PurchaseSaleDetail.includes(:purchase_sale_items).joins(:purchase_sale_items).where(:transaction_type=>"SaleReturn").ransack(params[:q])
      @accounts=Account.all
    end
    if @q.result.count > 0
      @q.sorts = 'id desc' if @q.sorts.empty?
    end
    purchase_sale_detail = @q.result
    purchase_sale_detail_k = @k.result.distinct("purchase_sale_details.id").pluck(:id)
    @purchase_sale_details = purchase_sale_detail.page(params[:page]).per(100)
    @suppliers=SysUser.where(:user_group=>['Supplier','Both', 'Own'])
    @customers=SysUser.where(:user_group=>['Customer','Supplier','Both','Salesman'])
    @staffs=Staff.loader_active_staff
    @staffs=Staff.all if pos_setting_sys_type=="HousingScheme"
    @total_bil = PurchaseSaleDetail.where(id: purchase_sale_detail_k).sum(:total_bill)
    @total_am = PurchaseSaleDetail.where(id: purchase_sale_detail_k).sum(:amount)
    @total_dis=PurchaseSaleDetail.where(id: purchase_sale_detail_k).sum(:discount_price)
    @total_profit= PurchaseSaleItem.where(purchase_sale_detail_id: purchase_sale_detail ).sum('total_sale_price-total_cost_price')

      if params[:purchase_submit].present? or params[:sale_submit].present?
        product_id= params[:q][:purchase_sale_items_product_product_id].present? ? params[:q][:purchase_sale_items_product_product_id] : @products
        @sys_users = SysUser.all
        sys_user_id = params[:q][:sys_user_id_eq].present? ? params[:q][:sys_user_id_eq] : @sys_users
        staff =  params[:q][:staff_id_eq] if params[:q][:staff_id_eq].present?
        user_name =  params[:q][:user_name_eq] if params[:q][:user_name_eq].present?
        if params[:sale_submit].present?
          # @products_sale =  PurchaseSaleItem.joins(:product).where(product_id:product_id, created_at: @created_at_gteq.to_date.beginning_of_day..@created_at_lteq.to_date.end_of_day).group(:title).sum(:total_sale_price)
          # @products_sale_total =  PurchaseSaleItem.joins(:product).where(product_id:product_id, created_at: @created_at_gteq.to_date.beginning_of_day..@created_at_lteq.to_date.end_of_day).sum(:total_sale_price)
          # @products_count = PurchaseSaleItem.joins(:product).where(product_id:product_id, created_at: @created_at_gteq.to_date.beginning_of_day..@created_at_lteq.to_date.end_of_day,transaction_type: "Sale").group(:title).sum('purchase_sale_items.quantity')
          if staff
            if user_name
              @products_sale_price = PurchaseSaleDetail.joins(purchase_sale_items: :product).where(transaction_type: "SaleReturn").where('purchase_sale_items.product_id':product_id).where(sys_user_id: sys_user_id,  'purchase_sale_items.created_at': @created_at_gteq.to_date.beginning_of_day..@created_at_lteq.to_date.end_of_day,transaction_type: "SaleReturn",staff_id: staff, user_name: user_name).group(:title).average('purchase_sale_items.sale_price')
              @products_sale = PurchaseSaleDetail.joins(purchase_sale_items: :product).where(transaction_type: "SaleReturn").where('purchase_sale_items.product_id':product_id).where(sys_user_id: sys_user_id,  'purchase_sale_items.created_at': @created_at_gteq.to_date.beginning_of_day..@created_at_lteq.to_date.end_of_day,transaction_type: "SaleReturn",staff_id: staff, user_name: user_name).group(:title).sum(:total_sale_price)
              @products_sale_count = PurchaseSaleDetail.joins(purchase_sale_items: :product).where(transaction_type: "SaleReturn").where('purchase_sale_items.product_id':product_id).where(sys_user_id: sys_user_id, 'purchase_sale_items.created_at': @created_at_gteq.to_date.beginning_of_day..@created_at_lteq.to_date.end_of_day,transaction_type: "SaleReturn",staff_id: staff, user_name: user_name).group(:title).sum('purchase_sale_items.quantity')
              @products_sale_total = PurchaseSaleDetail.joins(purchase_sale_items: :product).where(transaction_type: "SaleReturn").where('purchase_sale_items.product_id':product_id).where(sys_user_id: sys_user_id, 'purchase_sale_items.created_at': @created_at_gteq.to_date.beginning_of_day..@created_at_lteq.to_date.end_of_day,transaction_type: "SaleReturn",staff_id: staff, user_name: user_name).sum(:total_sale_price)
            else
              @products_sale_price = PurchaseSaleDetail.joins(purchase_sale_items: :product).where(transaction_type: "SaleReturn").where('purchase_sale_items.product_id':product_id).where(sys_user_id: sys_user_id,  'purchase_sale_items.created_at': @created_at_gteq.to_date.beginning_of_day..@created_at_lteq.to_date.end_of_day,transaction_type: "SaleReturn",staff_id: staff).group(:title).average(:sale_price)
              @products_sale = PurchaseSaleDetail.joins(purchase_sale_items: :product).where(transaction_type: "SaleReturn").where('purchase_sale_items.product_id':product_id).where(sys_user_id: sys_user_id,  'purchase_sale_items.created_at': @created_at_gteq.to_date.beginning_of_day..@created_at_lteq.to_date.end_of_day,transaction_type: "SaleReturn",staff_id: staff).group(:title).sum(:total_sale_price)
              @products_count = PurchaseSaleDetail.joins(purchase_sale_items: :product).where(transaction_type: "SaleReturn").where('purchase_sale_items.product_id':product_id).where(sys_user_id: sys_user_id, 'purchase_sale_items.created_at': @created_at_gteq.to_date.beginning_of_day..@created_at_lteq.to_date.end_of_day,transaction_type: "SaleReturn",staff_id: staff).group(:title).sum('purchase_sale_items.quantity')
              @products_sale_total = PurchaseSaleDetail.joins(purchase_sale_items: :product).where(transaction_type: "SaleReturn").where('purchase_sale_items.product_id':product_id).where(sys_user_id: sys_user_id, 'purchase_sale_items.created_at': @created_at_gteq.to_date.beginning_of_day..@created_at_lteq.to_date.end_of_day,transaction_type: "SaleReturn",staff_id: staff).sum(:total_sale_price)
            end
          else
            if user_name
              @products_sale_price = PurchaseSaleDetail.joins(purchase_sale_items: :product).where(transaction_type: "SaleReturn").where('purchase_sale_items.product_id':product_id).where(sys_user_id: sys_user_id,  'purchase_sale_items.created_at': @created_at_gteq.to_date.beginning_of_day..@created_at_lteq.to_date.end_of_day,transaction_type: "SaleReturn", user_name: user_name).group(:title).average('purchase_sale_items.sale_price')
              @products_sale = PurchaseSaleDetail.joins(purchase_sale_items: :product).where(transaction_type: "SaleReturn").where('purchase_sale_items.product_id':product_id).where(sys_user_id: sys_user_id,  'purchase_sale_items.created_at': @created_at_gteq.to_date.beginning_of_day..@created_at_lteq.to_date.end_of_day,transaction_type: "SaleReturn", user_name: user_name).group(:title).sum(:total_sale_price)
              @products_count = PurchaseSaleDetail.joins(purchase_sale_items: :product).where(transaction_type: "SaleReturn").where('purchase_sale_items.product_id':product_id).where(sys_user_id: sys_user_id, 'purchase_sale_items.created_at': @created_at_gteq.to_date.beginning_of_day..@created_at_lteq.to_date.end_of_day,transaction_type: "SaleReturn", user_name: user_name).group(:title).sum('purchase_sale_items.quantity')
              @products_sale_total = PurchaseSaleDetail.joins(purchase_sale_items: :product).where(transaction_type: "SaleReturn").where('purchase_sale_items.product_id':product_id).where(sys_user_id: sys_user_id, 'purchase_sale_items.created_at': @created_at_gteq.to_date.beginning_of_day..@created_at_lteq.to_date.end_of_day,transaction_type: "SaleReturn", user_name: user_name).sum(:total_sale_price)
            else
              @products_sale_price = PurchaseSaleDetail.joins(purchase_sale_items: :product).where(transaction_type: "SaleReturn").where('purchase_sale_items.product_id':product_id).where(sys_user_id: sys_user_id,  'purchase_sale_items.created_at': @created_at_gteq.to_date.beginning_of_day..@created_at_lteq.to_date.end_of_day,transaction_type: "SaleReturn").group(:title).average('purchase_sale_items.sale_price')
              @products_sale = PurchaseSaleDetail.joins(purchase_sale_items: :product).where(transaction_type: "SaleReturn").where('purchase_sale_items.product_id':product_id).where(sys_user_id: sys_user_id,  'purchase_sale_items.created_at': @created_at_gteq.to_date.beginning_of_day..@created_at_lteq.to_date.end_of_day,transaction_type: "SaleReturn").group(:title).sum(:total_sale_price)
              @products_count = PurchaseSaleDetail.joins(purchase_sale_items: :product).where(transaction_type: "SaleReturn").where('purchase_sale_items.product_id':product_id).where(sys_user_id: sys_user_id, 'purchase_sale_items.created_at': @created_at_gteq.to_date.beginning_of_day..@created_at_lteq.to_date.end_of_day,transaction_type: "SaleReturn").group(:title).sum('purchase_sale_items.quantity')
              @products_sale_total = PurchaseSaleDetail.joins(purchase_sale_items: :product).where(transaction_type: "SaleReturn").where('purchase_sale_items.product_id':product_id).where(sys_user_id: sys_user_id, 'purchase_sale_items.created_at': @created_at_gteq.to_date.beginning_of_day..@created_at_lteq.to_date.end_of_day,transaction_type: "SaleReturn").sum(:total_sale_price)
            end
          end
          if user_name
            @product_carriage = PurchaseSaleDetail.joins(purchase_sale_items: :product).where(sys_user_id: sys_user_id,'purchase_sale_items.created_at': @created_at_gteq.to_date.beginning_of_day..@created_at_lteq.to_date.end_of_day,transaction_type: "SaleReturn",staff_id: staff, user_name: user_name).sum(:carriage)
            @product_loading = PurchaseSaleDetail.joins(purchase_sale_items: :product).where(sys_user_id: sys_user_id,'purchase_sale_items.created_at': @created_at_gteq.to_date.beginning_of_day..@created_at_lteq.to_date.end_of_day,transaction_type: "SaleReturn",staff_id: staff, user_name: user_name).sum(:loading)
          else
            @product_carriage = PurchaseSaleDetail.joins(purchase_sale_items: :product).where(sys_user_id: sys_user_id,'purchase_sale_items.created_at': @created_at_gteq.to_date.beginning_of_day..@created_at_lteq.to_date.end_of_day,transaction_type: "SaleReturn",staff_id: staff).sum(:carriage)
            @product_loading = PurchaseSaleDetail.joins(purchase_sale_items: :product).where(sys_user_id: sys_user_id,'purchase_sale_items.created_at': @created_at_gteq.to_date.beginning_of_day..@created_at_lteq.to_date.end_of_day,transaction_type: "SaleReturn",staff_id: staff).sum(:loading)
          end

        end
        if params[:purchase_submit] == "Total Purchase PDF A4" or params[:sale_submit] == "Total Sale PDF A4"
          respond_to do |format|
            request.format = 'pdf'
            format.html
            format.pdf do
              @pos_setting=PosSetting.first
              render pdf: '['+(PurchaseSaleDetail.where(id:@purchase_sale_details.ids).joins(:sys_user).pluck('name').uniq.join(' '))+']'+@created_at_gteq.to_s+'-'+@created_at_lteq.to_s,
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
        else
          respond_to do |format|
            request.format = 'pdf'
            format.html
            format.pdf do
              @pos_setting=PosSetting.first
              render pdf: '['+(PurchaseSaleDetail.where(id:@purchase_sale_details.ids).joins(:sys_user).pluck('name').uniq.join(' '))+']'+@created_at_gteq.to_s+'-'+@created_at_lteq.to_s,
              layout: 'pdf.html',
              page_size: 'A8',
              margin_top: '0',
              margin_right: '0',
              margin_bottom: '0',
              margin_left: '0',
              encoding: "UTF-8",
              show_as_html: true
            end
          end
        end
      end
      if params[:submit_pdf_staff_without].present? or params[:submit_pdf_staff_without_bulk].present? or params[:email].present?
        product_id= params[:q][:purchase_sale_items_product_product_id].present? ? params[:q][:purchase_sale_items_product_product_id] : @products
        @sys_users = SysUser.all
        sys_user_id = params[:q][:sys_user_id_eq].present? ? params[:q][:sys_user_id_eq] : @sys_users
        user_name =  params[:q][:user_name_eq] if params[:q][:user_name_eq].present?
        if params[:submit_pdf_staff_without].present? or params[:email].present? or params[:submit_pdf_staff_without_bulk].present?
          if staff
            if user_name
              @products_sale_price =  PurchaseSaleItem.joins(:purchase_sale_detail,:product).where(product_id:product_id, created_at: @created_at_gteq.to_date.beginning_of_day..@created_at_lteq.to_date.end_of_day,transaction_type: "SaleReturn",'purchase_sale_details.staff_id': staff, 'purchase_sale_details.user_name': user_name).group(:title).average(:sale_price)
              @products_sale =  PurchaseSaleItem.joins(:purchase_sale_detail,:product).where(product_id:product_id, created_at: @created_at_gteq.to_date.beginning_of_day..@created_at_lteq.to_date.end_of_day,transaction_type: "SaleReturn",'purchase_sale_details.staff_id': staff, 'purchase_sale_details.user_name': user_name).group(:title).sum(:total_sale_price)
              @products_count = PurchaseSaleItem.joins(:purchase_sale_detail,:product).where(product_id:product_id, created_at: @created_at_gteq.to_date.beginning_of_day..@created_at_lteq.to_date.end_of_day,transaction_type: "SaleReturn",'purchase_sale_details.staff_id': staff, 'purchase_sale_details.user_name': user_name).group(:title).sum('purchase_sale_items.quantity')
              @products_group = PurchaseSaleDetail.joins(purchase_sale_items: :product).where(sys_user_id: sys_user_id, created_at: @created_at_gteq.to_date.beginning_of_day..@created_at_lteq.to_date.end_of_day,transaction_type: "SaleReturn",staff_id: staff, user_name: user_name).group(:title).sum('purchase_sale_items.quantity')
              @products_group_count = PurchaseSaleDetail.joins(purchase_sale_items: :product).where(sys_user_id: sys_user_id, created_at: @created_at_gteq.to_date.beginning_of_day..@created_at_lteq.to_date.end_of_day,transaction_type: "SaleReturn",staff_id: staff, user_name: user_name).sum('purchase_sale_items.quantity')
            else
              @products_sale_price =  PurchaseSaleItem.joins(:purchase_sale_detail,:product).where(product_id:product_id, created_at: @created_at_gteq.to_date.beginning_of_day..@created_at_lteq.to_date.end_of_day,transaction_type: "SaleReturn",'purchase_sale_details.staff_id': staff).group(:title).average(:sale_price)
              @products_sale =  PurchaseSaleItem.joins(:purchase_sale_detail,:product).where(product_id:product_id, created_at: @created_at_gteq.to_date.beginning_of_day..@created_at_lteq.to_date.end_of_day,transaction_type: "SaleReturn",'purchase_sale_details.staff_id': staff).group(:title).sum(:total_sale_price)
              @products_count = PurchaseSaleItem.joins(:purchase_sale_detail,:product).where(product_id:product_id, created_at: @created_at_gteq.to_date.beginning_of_day..@created_at_lteq.to_date.end_of_day,transaction_type: "SaleReturn",'purchase_sale_details.staff_id': staff).group(:title).sum('purchase_sale_items.quantity')
              @products_group = PurchaseSaleDetail.joins(purchase_sale_items: :product).where(sys_user_id: sys_user_id, created_at: @created_at_gteq.to_date.beginning_of_day..@created_at_lteq.to_date.end_of_day,transaction_type: "SaleReturn",staff_id: staff).group(:title).sum('purchase_sale_items.quantity')
              @products_group_count = PurchaseSaleDetail.joins(purchase_sale_items: :product).where(sys_user_id: sys_user_id, created_at: @created_at_gteq.to_date.beginning_of_day..@created_at_lteq.to_date.end_of_day,transaction_type: "SaleReturn",staff_id: staff).sum('purchase_sale_items.quantity')
            end
          else
            if user_name
              @products_sale_price =  PurchaseSaleItem.joins(:purchase_sale_detail,:product).where(product_id:product_id, created_at: @created_at_gteq.to_date.beginning_of_day..@created_at_lteq.to_date.end_of_day,transaction_type: "SaleReturn", 'purchase_sale_details.user_name': user_name).group(:title).average(:sale_price)
              @products_sale =  PurchaseSaleItem.joins(:purchase_sale_detail,:product).where(product_id:product_id, created_at: @created_at_gteq.to_date.beginning_of_day..@created_at_lteq.to_date.end_of_day,transaction_type: "SaleReturn", 'purchase_sale_details.user_name': user_name).group(:title).sum(:total_sale_price)
              @products_count = PurchaseSaleItem.joins(:purchase_sale_detail,:product).where(product_id:product_id, created_at: @created_at_gteq.to_date.beginning_of_day..@created_at_lteq.to_date.end_of_day,transaction_type: "SaleReturn", 'purchase_sale_details.user_name': user_name).group(:title).sum('purchase_sale_items.quantity')
              @products_group = PurchaseSaleDetail.joins(purchase_sale_items: :product).where(sys_user_id: sys_user_id, created_at: @created_at_gteq.to_date.beginning_of_day..@created_at_lteq.to_date.end_of_day,transaction_type: "SaleReturn", user_name: user_name).group(:title).sum('purchase_sale_items.quantity')
              @products_group_count = PurchaseSaleDetail.joins(purchase_sale_items: :product).where(sys_user_id: sys_user_id, created_at: @created_at_gteq.to_date.beginning_of_day..@created_at_lteq.to_date.end_of_day,transaction_type: "SaleReturn", user_name: user_name).sum('purchase_sale_items.quantity')
            else
              @products_sale_price =  PurchaseSaleItem.joins(:purchase_sale_detail,:product).where(product_id:product_id, created_at: @created_at_gteq.to_date.beginning_of_day..@created_at_lteq.to_date.end_of_day,transaction_type: "SaleReturn").group(:title).average(:sale_price)
              @products_sale =  PurchaseSaleItem.joins(:purchase_sale_detail,:product).where(product_id:product_id, created_at: @created_at_gteq.to_date.beginning_of_day..@created_at_lteq.to_date.end_of_day,transaction_type: "SaleReturn").group(:title).sum(:total_sale_price)
              @products_count = PurchaseSaleItem.joins(:purchase_sale_detail,:product).where(product_id:product_id, created_at: @created_at_gteq.to_date.beginning_of_day..@created_at_lteq.to_date.end_of_day,transaction_type: "SaleReturn").group(:title).sum('purchase_sale_items.quantity')
              @products_group = PurchaseSaleDetail.joins(purchase_sale_items: :product).where(sys_user_id: sys_user_id, created_at: @created_at_gteq.to_date.beginning_of_day..@created_at_lteq.to_date.end_of_day,transaction_type: "SaleReturn").group(:title).sum('purchase_sale_items.quantity')
              @products_group_count = PurchaseSaleDetail.joins(purchase_sale_items: :product).where(sys_user_id: sys_user_id, created_at: @created_at_gteq.to_date.beginning_of_day..@created_at_lteq.to_date.end_of_day,transaction_type: "SaleReturn").sum('purchase_sale_items.quantity')
            end
          end
        else
          if staff
            if user_name
              @products_sale_price =  PurchaseSaleItem.joins(:product).where(product_id:product_id, created_at: @created_at_gteq.to_date.beginning_of_day..@created_at_lteq.to_date.end_of_day,'purchase_sale_details.staff_id': staff).group(:title).average(:cost_price)
              @products_sale =  PurchaseSaleItem.joins(:product).where(product_id:product_id, created_at: @created_at_gteq.to_date.beginning_of_day..@created_at_lteq.to_date.end_of_day,'purchase_sale_details.staff_id': staff).group(:title).sum(:total_cost_price)
              @products_sale_total =  PurchaseSaleItem.joins(:product).where(product_id:product_id, created_at: @created_at_gteq.to_date.beginning_of_day..@created_at_lteq.to_date.end_of_day,'purchase_sale_details.staff_id': staff).sum(:total_cost_price)
              @products_count = PurchaseSaleItem.joins(:product).where(product_id:product_id, created_at: @created_at_gteq.to_date.beginning_of_day..@created_at_lteq.to_date.end_of_day,transaction_type: "Purchase",'purchase_sale_details.staff_id': staff).group(:title).sum('purchase_sale_items.quantity')
            else
              @products_sale_price =  PurchaseSaleItem.joins(:product).where(product_id:product_id, created_at: @created_at_gteq.to_date.beginning_of_day..@created_at_lteq.to_date.end_of_day,'purchase_sale_details.staff_id': staff).group(:title).average(:cost_price)
              @products_sale =  PurchaseSaleItem.joins(:product).where(product_id:product_id, created_at: @created_at_gteq.to_date.beginning_of_day..@created_at_lteq.to_date.end_of_day,'purchase_sale_details.staff_id': staff).group(:title).sum(:total_cost_price)
              @products_sale_total =  PurchaseSaleItem.joins(:product).where(product_id:product_id, created_at: @created_at_gteq.to_date.beginning_of_day..@created_at_lteq.to_date.end_of_day,'purchase_sale_details.staff_id': staff).sum(:total_cost_price)
              @products_count = PurchaseSaleItem.joins(:product).where(product_id:product_id, created_at: @created_at_gteq.to_date.beginning_of_day..@created_at_lteq.to_date.end_of_day,transaction_type: "Purchase",'purchase_sale_details.staff_id': staff).group(:title).sum('purchase_sale_items.quantity')
            end
          else
            if user_name
              @products_sale_price =  PurchaseSaleItem.joins(:product).where(product_id:product_id, created_at: @created_at_gteq.to_date.beginning_of_day..@created_at_lteq.to_date.end_of_day).group(:title).average(:cost_price)
              @products_sale =  PurchaseSaleItem.joins(:product).where(product_id:product_id, created_at: @created_at_gteq.to_date.beginning_of_day..@created_at_lteq.to_date.end_of_day).group(:title).sum(:total_cost_price)
              @products_sale_total =  PurchaseSaleItem.joins(:product).where(product_id:product_id, created_at: @created_at_gteq.to_date.beginning_of_day..@created_at_lteq.to_date.end_of_day).sum(:total_cost_price)
              @products_count = PurchaseSaleItem.joins(:product).where(product_id:product_id, created_at: @created_at_gteq.to_date.beginning_of_day..@created_at_lteq.to_date.end_of_day,transaction_type: "SaleReturn").group(:title).sum('purchase_sale_items.quantity')
            else
              @products_sale_price =  PurchaseSaleItem.joins(:product).where(product_id:product_id, created_at: @created_at_gteq.to_date.beginning_of_day..@created_at_lteq.to_date.end_of_day).group(:title).average(:cost_price)
              @products_sale =  PurchaseSaleItem.joins(:product).where(product_id:product_id, created_at: @created_at_gteq.to_date.beginning_of_day..@created_at_lteq.to_date.end_of_day).group(:title).sum(:total_cost_price)
              @products_sale_total =  PurchaseSaleItem.joins(:product).where(product_id:product_id, created_at: @created_at_gteq.to_date.beginning_of_day..@created_at_lteq.to_date.end_of_day).sum(:total_cost_price)
              @products_count = PurchaseSaleItem.joins(:product).where(product_id:product_id, created_at: @created_at_gteq.to_date.beginning_of_day..@created_at_lteq.to_date.end_of_day,transaction_type: "SaleReturn").group(:title).sum('purchase_sale_items.quantity')
            end
          end
        end
        if params[:email].present?
          @pos_setting=PosSetting.first
          @purchase_sale_details_pdf = @q.result
          @pdf_sale=render_to_string(:pdf => "Sale Detail Full",:template => 'layouts/index_batha.pdf.erb',:filename => 'Sale Detail')
          @pdf_index=render_to_string(:pdf => "Sale Detail Short",:template => 'purchase_sale_details/index.pdf.erb',:filename => 'Totay Short Sale Detail')
        else
          if params[:submit_pdf_staff_without_bulk].present?
            respond_to do |format|
              request.format = 'pdf'
              format.html
              format.pdf do
                @pos_setting=PosSetting.first
                @purchase_sale_details_pdf = @q.result
                render pdf: '['+(PurchaseSaleDetail.where(id:@purchase_sale_details_pdf.ids).joins(:sys_user).pluck('name').uniq.join(' '))+']'+@created_at_gteq.to_s+'-'+@created_at_lteq.to_s,
                layout: 'invoice_bulk.pdf',
                page_size: 'A4',
                margin_top: '0',
                margin_right: '0',
                margin_bottom: '0',
                margin_left: '0',
                footer:  {             # optional, use 'pdf_plain' for a pdf_plain.html.pdf.erb file, defaults to main layout
                  right: '[page] of [topage]'},
                show_as_html: false
              end
            end
          else
            respond_to do |format|
              request.format = 'pdf'
              format.html
              format.pdf do
                @pos_setting=PosSetting.first
                @purchase_sale_details_pdf = @q.result
                render pdf: '['+(PurchaseSaleDetail.where(id:@purchase_sale_details_pdf.ids).joins(:sys_user).pluck('name').uniq.join(' '))+']'+@created_at_gteq.to_s+'-'+@created_at_lteq.to_s,
                layout: 'index_batha.pdf',
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

      end
      if params[:email].present?
        @pos_setting=PosSetting.first
        @purchase_sale_details_pdf = @q.result
        subject = "#{@pos_setting.display_name} - Sale Detail - From #{@created_at_gteq.to_date} To #{@created_at_lteq.to_date}"
        email = current_user.superAdmin.email_to.present? ? current_user.superAdmin.email_to : "info@munshionclick.com"
        pdf=[[@pdf_sale,'Sale_Detail'],[@pdf_index,"Sale"]]
        body=@products_sale
        ReportMailer.new_report_email(pdf,subject,email,"").deliver
        return redirect_to purchase_sale_details_path(sale: true)
      end
  end
  # GET /purchase_sale_details/1
  # GET /purchase_sale_details/1.json
  def show
    @pos_setting=PosSetting.first
    if @pos_setting.is_qr.present? && @pos_setting.website.present?
      require "rqrcode"
      qrcode = RQRCode::QRCode.new(@pos_setting.website)
      @svg = qrcode.as_svg(
          color: "000",
          shape_rendering: "crispEdges",
          module_size: 11,
          standalone: true,
          use_path: true
        )
      @str=Base64.encode64(@svg ).gsub("\n", '')
    end
    @id=PurchaseSaleDetail.where(created_at: Time.zone.now.beginning_of_day..Time.zone.now.end_of_day).count
    request.format = 'pdf'
    if @pos_setting.sys_type=="industry" || @pos_setting.sys_type =="HousingScheme"
      @profile_image_url = @purchase_sale_detail.order.sys_user.profile_image.url
      name = @purchase_sale_detail.sys_user.name+' Invoice #'+@purchase_sale_detail.id.to_s
      respond_to do |format|
        format.html
        format.pdf do
          print_pdf(name,'pdf.html','A4')
        end
      end
    elsif params[:pdf]
      request.format = 'pdf'
      name = @purchase_sale_detail.sys_user.name+' Invoice #'+@purchase_sale_detail.id.to_s
      print_pdf(name,'pdf.html','A4')
    elsif @pos_setting.sys_type=="FastFood"
      render :partial => "/purchase_sale_details/fast_food/create"
    else
      name = @purchase_sale_detail.sys_user.name+' Invoice #'+@purchase_sale_detail.id.to_s
      respond_to do |format|
        format.html
        format.pdf do
          render pdf: name,
          layout: 'pdf.html',
          page_size: @pos_setting.purchase_sale_detail_show_page_size,
          margin:  {
          		top: @pos_setting.pdf_margin_top.to_f,
              bottom: @pos_setting.pdf_margin_right.to_f,
              left:  @pos_setting.pdf_margin_bottom.to_f,
              right: @pos_setting.pdf_margin_left.to_f
          },
          encoding: "UTF-8",
          show_as_html: true
        end
      end
    end
  end
  # GET /purchase_sale_details/new
  def new
    @purchase_sale_details=PurchaseSaleDetail.all
    @account=current_user.user_account
    @pos_setting=PosSetting.first
    @pos_type_batha=pos_type_batha
    @departments=Department.all
    @purchase_sale_detail = PurchaseSaleDetail.new(order_id:params[:order_id],sys_user_id:params[:sys_user_id])
    if params[:duplicate].present?
      @purchase_sale_detail=PurchaseSaleDetail.find(params[:id]).dup
      @purchase_sale_detail.amount=0
    end
    if params[:order_id].present?
      order=Order.find(params[:order_id])
      unless order.purchase_sale_details.present?
        order.order_items.each do |oi|
          @purchase_sale_detail.purchase_sale_items.build(product_id: oi.product_id,item_id: oi.item_id,quantity:oi.quantity,cost_price:oi.cost_price,sale_price:oi.sale_price)
          @purchase_sale_detail.product_warranties.build(product_id: oi.product_id) if oi.product.with_serial
        end
      end
    elsif params[:purchase_sale_detail_id].present? && params[:purchase_sale_type]=="SaleReturn"
      @return_purchase_sale_detail=PurchaseSaleDetail.find(params[:purchase_sale_detail_id])
      if @return_purchase_sale_detail.present?
        @purchase_sale_detail.sys_user_id = @return_purchase_sale_detail.sys_user_id
        @return_purchase_sale_detail.purchase_sale_items.each do |oi|
          @purchase_sale_detail.purchase_sale_items.build(product_id: oi.product_id,item_id: oi.item_id,quantity:oi.quantity,cost_price:oi.cost_price,sale_price:oi.sale_price,purchase_sale_type:'Return_type')
        end
        @return_purchase_sale_detail.product_warranties.each do |oi|
          @purchase_sale_detail.product_warranties.build(product_id: oi.product_id,serial: oi.serial)
        end
      end
    else
      @purchase_sale_detail.purchase_sale_items.build
    end
    @suppliers=SysUser.where(:user_group=>['Supplier','Both','Own'])
    @customers=SysUser.where(:user_group=>['Customer','Both','Salesman'])
    @items=Item.all
    @products=Product.all
    @accounts=Account.all
    @orders=Order.all
    @staffs=Staff.all
    @staffs=Staff.where(department_id: @departments.fourth.id) if @pos_type_batha
    @expense_types = ExpenseType.all
    @accounts=Account.all
  end
  # GET /purchase_sale_details/1/edit
  def edit
    @account=@purchase_sale_detail.account_id
    @pos_setting=PosSetting.first
    @pos_type_batha=pos_type_batha
    @departments=Department.all
    @return_products=Product.where(id:@purchase_sale_detail.purchase_sale_items.pluck(:product_id))
    @suppliers=SysUser.where(:user_group=>['Supplier','Both','Own'])
    @items=Item.all
    @customers=SysUser.where(:user_group=>['Customer','Both','Salesman'])
    @products=Product.all
    @accounts=Account.all
    @orders=Order.all
    @expense_types = ExpenseType.all
    @staffs=Staff.all
    @staffs=Staff.where(department_id: @departments.fourth.id) if @pos_type_batha
    if @pos_setting.sys_type=="FastFood"
      order = @purchase_sale_detail.order
      @purchase_sale_detail.purchase_sale_items.destroy_all
      order.order_items.each do |oi|
        @purchase_sale_detail.purchase_sale_items.build(product_id: oi.product_id,item_id: oi.item_id,quantity:oi.quantity,cost_price:oi.cost_price,sale_price:oi.sale_price)
        @purchase_sale_detail.product_warranties.build(product_id: oi.product_id) if oi.product.with_serial
      end
    end
  end
  # POST /purchase_sale_details
  # POST /purchase_sale_details.json
  def create
    @pos_setting=PosSetting.first
    if @pos_setting.is_qr.present? && @pos_setting.website.present?
      require "rqrcode"
      qrcode = RQRCode::QRCode.new(@pos_setting.website)
      @svg = qrcode.as_svg(
          color: "000",
          shape_rendering: "crispEdges",
          module_size: 11,
          standalone: true,
          use_path: true
        )
      @str=Base64.encode64(@svg ).gsub("\n", '')
    end
    @sysuser=SysUser.find_by_id(purchase_sale_detail_params[:sys_user_id]).present? ? SysUser.find_by_id(purchase_sale_detail_params[:sys_user_id]) : SysUser.first
    balance=@sysuser.balance
    bill=purchase_sale_detail_params[:total_bill].to_f-purchase_sale_detail_params[:discount_price].to_f
    if @sysuser.user_group!="Supplier" && purchase_sale_detail_params[:transaction_type]=="Sale"
      fullbalance=-bill+purchase_sale_detail_params[:amount].to_f+(balance.to_f)
    else
      fullbalance=(balance.to_f+(bill.to_f))-purchase_sale_detail_params[:amount].to_f
    end
    @time = Time.zone.now
    PurchaseSaleDetail.maximum(:id).present? ? psd=PurchaseSaleDetail.maximum(:id).next : psd=1
    @purchase_sale_detail = PurchaseSaleDetail.new(purchase_sale_detail_params)
    @id=PurchaseSaleDetail.where(created_at: Time.zone.now.beginning_of_day..Time.zone.now.end_of_day).count+1
    @purchase_sale_detail.voucher_id=@id
    @purchase_sale_detail.user_name=current_user.name
    respond_to do |format|
      if @purchase_sale_detail.save!
        PaymentBalanceJob.perform_later(current_user.superAdmin.company_type, @purchase_sale_detail&.account&.id)
        @purchase_sale_detail.purchase_sale_items.each do |purchase|
          product=purchase.product
          if product.present? && pos_setting_sys_type == 'MobileShop'
            warranties_sale=ProductWarranty.includes(:product).joins(:purchase_sale_detail).where('purchase_sale_details.transaction_type':'Sale',product_id: product.id)
            warranties_purchase=ProductWarranty.includes(:product).joins(:purchase_sale_detail).where('purchase_sale_details.transaction_type':'Purchase',product_id: 	product.id)
            if (warranties_sale || warranties_purchase)
              sale_array=[]
              purchase_array=[]
              warranties_sale.pluck(:serial).compact.uniq.map(&:upcase).each do |purchase|
                purchase.upcase.split("\r\n").each do |purch|
                  sale_array << purch
                end
              end
              warranties_purchase.pluck(:serial).compact.uniq.map(&:upcase).each do |purchase|
                purchase.upcase.split("\r\n").each do |purch|
                  purchase_array << purch
                end
              end
              list=String.new
              (purchase_array-sale_array).select{|s| list=s+' '+list}
              product.update(warranty_list: list.gsub(' ',"\r\n")[0...-2])
            end
          end
        end
        if (params[:commit]=="Save" || params[:commit]=="Save with Print") && @purchase_sale_detail.transaction_type=='Sale'
          if user_type(@sysuser.id)!='Supplier'
            @ledger_book = LedgerBook.new(sys_user_id: @sysuser.id,debit:(bill),credit:purchase_sale_detail_params[:amount].to_f,balance:fullbalance,comment:"Voucher #"+psd.to_s+"  ||  "+(purchase_sale_detail_params["created_at(3i)"])+"/"+(purchase_sale_detail_params["created_at(2i)"])+"/"+(purchase_sale_detail_params["created_at(1i)"])+" "+@time.strftime("at %I:%M%p"),purchase_sale_detail_id: @purchase_sale_detail.id)
            @ledger_book.save!
          else
            @ledger_book = LedgerBook.new(sys_user_id: @sysuser.id,debit:purchase_sale_detail_params[:amount].to_f,credit:(bill),balance:fullbalance,comment:"Voucher #"+psd.to_s+"  ||  "+(purchase_sale_detail_params["created_at(3i)"])+"/"+(purchase_sale_detail_params["created_at(2i)"])+"/"+(purchase_sale_detail_params["created_at(1i)"])+" "+@time.strftime("at %I:%M%p"),purchase_sale_detail_id: @purchase_sale_detail.id)
            @ledger_book.save!
          end
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
          if @pos_setting.sys_type=="industry" || @pos_setting.sys_type =="HousingScheme"
            if params[:commit]=="Save with Print"
              request.format = 'pdf'
              format.pdf do
                name = @purchase_sale_detail.sys_user.name+' Invoice #'+@purchase_sale_detail.id.to_s
                print_pdf(name,'pdf.html','A4')
              end
            end
            if @pos_setting.sms_templates.present?
              send_sms(@purchase_sale_detail.sys_user&.contact&.phone_with_comma,@pos_setting.sms_templates["new_invoice"],'','') if @pos_setting.sms_templates["new_invoice"].present? && @purchase_sale_detail.amount.to_f > 0
              send_sms(@purchase_sale_detail.sys_user&.contact&.phone_with_comma,@pos_setting.sms_templates["new_fine"],'','') if @pos_setting.sms_templates["new_fine"].present? && @purchase_sale_detail.order.present? && @purchase_sale_detail.order.purchase_sale_details.count > 1 && @purchase_sale_detail.purchase_sale_items.count > 0
            end
          else
            if params[:commit]=="Save with Print"
              if @pos_setting.sys_type=="FastFood"
                format.html {render :partial => "/purchase_sale_details/fast_food/create"}
              else
                request.format = 'pdf'
                format.pdf do
                  name = @purchase_sale_detail.sys_user.name+' Invoice #'+@purchase_sale_detail.id.to_s
                  print_pdf(name,'pdf.html','A4',true)
                end
              end
            end
          end
          if @pos_setting.sys_type!="FastFood"
            format.html { redirect_to new_purchase_sale_detail_path(transaction_type: :sale,product: true), notice: 'Sale was successfully created.' }
          else
            format.html { redirect_to biller_orders_path, notice: 'Sale was successfully created.' }
          end
        else
          @purchase_sale_detail.purchase_sale_items.each do |purchase|
            product=purchase.product
            if product.present? && pos_setting_sys_type == 'MobileShop'
              warranties_sale=ProductWarranty.includes(:product).joins(:purchase_sale_detail).where('purchase_sale_details.transaction_type':'Sale',product_id: product.id)
              warranties_purchase=ProductWarranty.includes(:product).joins(:purchase_sale_detail).where('purchase_sale_details.transaction_type':'Purchase',product_id: 	product.id)
              if warranties_sale || warranties_purchase
                sale_array=[]
                purchase_array=[]
                warranties_sale.pluck(:serial).compact.uniq.map(&:upcase).each do |purchase|
                  purchase.upcase.split("\r\n").each do |purch|
                    sale_array << purch
                  end
                end
                warranties_purchase.pluck(:serial).compact.uniq.map(&:upcase).each do |purchase|
                  purchase.upcase.split("\r\n").each do |purch|
                    purchase_array << purch
                  end
                end
                list=String.new
                (purchase_array-sale_array).select{|s| list=s+' '+list}
                product.update(warranty_list: list.gsub(' ',"\r\n")[0...-2])
              end
            end
          end
          @ledger_book = LedgerBook.new(sys_user_id: @sysuser.id,debit:purchase_sale_detail_params[:amount].to_f,credit:(bill),balance:fullbalance,comment:"Voucher #"+psd.to_s+"  ||  "+(purchase_sale_detail_params["created_at(3i)"])+"/"+(purchase_sale_detail_params["created_at(2i)"])+"/"+(purchase_sale_detail_params["created_at(1i)"])+" "+@time.strftime("at %I:%M%p"),purchase_sale_detail_id: @purchase_sale_detail.id,account_id: @purchase_sale_detail.account_id)
          @ledger_book.save!
          format.html { redirect_to purchase_sale_details_path, notice: 'Purchase was successfully created.' }
        end
        format.json { render :show, status: :created, location: @purchase_sale_detail }
      else
        @pos_type_batha=pos_type_batha
        @departments=Department.all
        @suppliers=SysUser.where(:user_group=>['Supplier','Both','Own'])
        @customers=SysUser.where(:user_group=>['Customer','Both','Salesman'])
        @items=Item.all
        @products=Product.all
        @accounts=Account.all
        @orders=Order.all
        @staffs=Staff.where(department_id: @departments.fourth.id) if @pos_type_batha
        @staffs=Staff.all if pos_setting_sys_type=="HousingScheme"
        @expense_types = ExpenseType.all
        @accounts=Account.all
        format.html { render :new }
        format.json { render json: @purchase_sale_detail.errors, status: :unprocessable_entity }
      end
    end
  end

  def day_out
    @products_sale =  PurchaseSaleItem.joins(:product).where(created_at:Time.zone.now.beginning_of_day..Time.zone.now.end_of_day).group(:title).sum(:total_sale_price).round(2)
    @products_sale_total =  PurchaseSaleItem.joins(:product).where(created_at:Time.zone.now.beginning_of_day..Time.zone.now.end_of_day).sum(:total_sale_price).round(2)
    @products_count = PurchaseSaleItem.joins(:product).where(created_at:Time.zone.now.beginning_of_day..Time.zone.now.end_of_day).group(:title).sum(:quantity).round(2)
    request.format = 'pdf'
    respond_to do |format|
      format.html
      format.pdf do
        render pdf: "Day-Out",
        layout: 'pdf.html',
        page_size: 'A8',
        margin_top: '0',
        margin_right: '0',
        margin_bottom: '0',
        margin_left: '0',
        encoding: "UTF-8",
        show_as_html: true
      end
    end
  end
  # PATCH/PUT /purchase_sale_details/1
  # PATCH/PUT /purchase_sale_details/1.json
  def update
    @pos_setting=PosSetting.first
    respond_to do |format|
      purchase=Hash.new
      @purchase_sale_detail.purchase_sale_items.each do |item|
        purchase[item.product_id]=item.quantity if item.product_id.present?
      end
      before_update_carriage_loading = @purchase_sale_detail.carriage+@purchase_sale_detail.loading
      @before_products_cost=@purchase_sale_detail.purchase_sale_items.group(:product_id).sum(:cost_price)
      @before_products_quantity=@purchase_sale_detail.purchase_sale_items.group(:product_id).sum('purchase_sale_items.quantity')
      @before_products_count=@purchase_sale_detail.purchase_sale_items.group(:product_id).count
      product_list = Product.where(id: @purchase_sale_detail.purchase_sale_items.pluck(:product_id))
      if @purchase_sale_detail.update!(purchase_sale_detail_params)
        if @purchase_sale_detail.transaction_type=='Sale'
          product_list.each do |product|
            if product.present? && pos_setting_sys_type == 'MobileShop'
              warranties_sale=ProductWarranty.includes(:product).joins(:purchase_sale_detail).where('purchase_sale_details.transaction_type':'Sale',product_id: product.id)
              warranties_purchase=ProductWarranty.includes(:product).joins(:purchase_sale_detail).where('purchase_sale_details.transaction_type':'Purchase',product_id: 	product.id)
              if warranties_sale || warranties_purchase
                sale_array=[]
                purchase_array=[]
                warranties_sale.pluck(:serial).compact.uniq.map(&:upcase).each do |purchase|
                  purchase.upcase.split("\r\n").each do |purch|
                    sale_array << purch
                  end
                end
                warranties_purchase.pluck(:serial).compact.uniq.map(&:upcase).each do |purchase|
                  purchase.upcase.split("\r\n").each do |purch|
                    purchase_array << purch
                  end
                end
                list=String.new
                (purchase_array-sale_array).select{|s| list=s+' '+list}
                product.update(warranty_list: list.gsub(' ',"\r\n")[0...-2])
              end
            end
          end
          @purchase_sale_detail.purchase_sale_items.update_all('total_cost_price=cost_price*quantity')
          products=@purchase_sale_detail.purchase_sale_items.pluck(:product_id,'purchase_sale_items.quantity',:cost_price)
          products.each do |product|
            if purchase[product.first].present?
              product_quantity = purchase[product.first].to_f-product.second.to_f
              productstock = Product.find(product.first)
              if @before_products_quantity[product.first]>product.second.to_f
                cost_price=((productstock.cost.to_f*(([productstock.stock, 0].max).to_f))+(product.last.to_f*(@before_products_quantity[product.first]-product.second.to_f)))/([productstock.stock, 0].max.to_f+(@before_products_quantity[product.first]-product.second.to_f))
                productstock.update!(stock: productstock.stock+product_quantity,cost:cost_price)
              elsif @before_products_quantity[product.first]<product.second.to_f
                purchase_sale_item=@purchase_sale_detail.purchase_sale_items.where(product_id:product.first)
                purchase_sale_item.each do |p|
                  p.update(cost_price:((productstock.cost.to_f*@before_products_quantity[product.first].to_f)+((product.second.to_f-@before_products_quantity[product.first].to_f)*p.cost_price.to_f))/(product.second.to_f))
                  p.update(total_cost_price:(p.reload.cost_price.to_f*p.reload.quantity.to_f))
                end
                productstock.update!(stock: productstock.stock+product_quantity)
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
          if @pos_setting.sms_templates.present?
            send_sms(@purchase_sale_detail.sys_user&.contact&.phone_with_comma,@pos_setting.sms_templates["update_invoice"],'','') if @pos_setting.sms_templates["update_invoice"].present? && @purchase_sale_detail.amount.to_f > 0
            send_sms(@purchase_sale_detail.sys_user&.contact&.phone_with_comma,@pos_setting.sms_templates["update_fine"],'','') if @pos_setting.sms_templates["update_fine"].present? && @purchase_sale_detail.order.present? && @purchase_sale_detail.order.purchase_sale_details.count > 1 && @purchase_sale_detail.purchase_sale_items.count > 0
          end

          UserLedgerBookJob.perform_later(current_user.superAdmin.company_type,@purchase_sale_detail.sys_user_id)
          AccountPaymentJob.perform_later(current_user.superAdmin.company_type,@purchase_sale_detail.account_id)
          SalaryDetailJob.perform_later(current_user.superAdmin.company_type,@purchase_sale_detail.staff_id)

          if params[:commit]=="Save with Print" and @purchase_sale_detail.with_gst.present?
            return redirect_to purchase_sale_detail_path(@purchase_sale_detail,with_gst:true)
          elsif params[:commit]=="Save with Print"
            return redirect_to purchase_sale_detail_path(@purchase_sale_detail)
          end
          if @pos_setting.sys_type!="FastFood"
            format.html { redirect_to new_purchase_sale_detail_path(transaction_type: :sale,product: true), notice: 'Sale was successfully created.' }
          else
            format.html { redirect_to biller_orders_path, notice: 'Sale detail was successfully updated.' }
          end
        else
          @purchase_sale_detail.purchase_sale_items.each do |purchase|
            product=purchase.product
            if product.present? && pos_setting_sys_type == 'MobileShop'
              warranties_sale=ProductWarranty.includes(:product).joins(:purchase_sale_detail).where('purchase_sale_details.transaction_type':'Sale',product_id: product.id)
              warranties_purchase=ProductWarranty.includes(:product).joins(:purchase_sale_detail).where('purchase_sale_details.transaction_type':'Purchase',product_id: 	product.id)
              if warranties_sale || warranties_purchase
                sale_array=[]
                purchase_array=[]
                warranties_sale.pluck(:serial).compact.uniq.map(&:upcase).each do |purchase|
                  purchase.upcase.split("\r\n").each do |purch|
                    sale_array << purch
                  end
                end
                warranties_purchase.pluck(:serial).compact.uniq.map(&:upcase).each do |purchase|
                  purchase.upcase.split("\r\n").each do |purch|
                    purchase_array << purch
                  end
                end
                list=String.new
                (purchase_array-sale_array).select{|s| list=s+' '+list}
                product.update(warranty_list: list.gsub(' ',"\r\n")[0...-2])
              end
            end
          end
          products=@purchase_sale_detail.purchase_sale_items.pluck(:product_id,'purchase_sale_items.quantity',:cost_price)
          products.each do |product|
            if purchase[product.first].present?
              product_quantity = product.second.to_f-purchase[product.first].to_f
              productstock = Product.find(product.first)
              cost_price=(((productstock.cost.to_f)*(([productstock.stock.to_f, 0].max).to_f))-((@before_products_cost[product.first].to_f/@before_products_count[product.first].to_f)*@before_products_quantity[product.first].to_f)+(product.last.to_f*product.second.to_f))/([productstock.stock.to_f, 0].max.to_f+product.second.to_f-@before_products_quantity[product.first].to_f)
              if cost_price.present? && !cost_price.nan?
                productstock.update!(stock: productstock.stock.to_f+product_quantity,cost: cost_price.to_f)
              else
                productstock.update!(stock: productstock.stock.to_f+product_quantity)
              end
            end
          end

          UserLedgerBookJob.perform_later(current_user.superAdmin.company_type,@purchase_sale_detail.sys_user_id)
          AccountPaymentJob.perform_later(current_user.superAdmin.company_type,@purchase_sale_detail.account_id)
          SalaryDetailJob.perform_later(current_user.superAdmin.company_type,@purchase_sale_detail.staff_id)

          format.html { redirect_to purchase_sale_details_path, notice: 'Purchase detail was successfully updated.' }
        end
        format.json { render :show, status: :ok, location: @purchase_sale_detail }
      else
        @departments=Department.all
        @suppliers=SysUser.where(:user_group=>['Supplier','Both','Own'])
        @customers=SysUser.where(:user_group=>['Customer','Both','Salesman'])
        @items=Item.all
        @products=Product.all
        @accounts=Account.all
        @orders=Order.all
        @staffs=Staff.where(department_id: @departments.fourth.id) if pos_setting_sys_type=="batha" or pos_setting_sys_type=="Factory"
        @staffs=Staff.all if pos_setting_sys_type=="HousingScheme"
        @expense_types = ExpenseType.all
        @accounts=Account.all
        format.html { render :edit }
        format.json { render json: @purchase_sale_detail.errors, status: :unprocessable_entity }
      end
    end
  end
  # DELETE /purchase_sale_details/1
  # DELETE /purchase_sale_details/1.json
  def destroy
    type=@purchase_sale_detail.transaction_type
    @products=Product.where(id:@purchase_sale_detail.purchase_sale_items.pluck(:product_id))
    # @purchase_sale_detail.purchase_sale_items.destroy_all if @purchase_sale_detail.purchase_sale_items.present?
    # @purchase_sale_detail.ledger_book.destroy if @purchase_sale_detail.ledger_book.present?
    # @purchase_sale_detail.salary_details.destroy if @purchase_sale_detail.salary_details.present?
    @purchase_sale_detail.destroy
    ledger_book = @purchase_sale_detail.sys_user.ledger_books.last
    UserLedgerBookJob.perform_later(current_user.superAdmin.company_type,@purchase_sale_detail.sys_user_id)
    AccountPaymentJob.perform_later(current_user.superAdmin.company_type,@purchase_sale_detail.account_id)
    SalaryDetailJob.perform_later(current_user.superAdmin.company_type,@purchase_sale_detail.staff_id)
    @products.each do |product|
      if product.present?
        warranties_sale=ProductWarranty.includes(:product).joins(:purchase_sale_detail).where('purchase_sale_details.transaction_type':'Sale',product_id: product.id)
        warranties_purchase=ProductWarranty.includes(:product).joins(:purchase_sale_detail).where('purchase_sale_details.transaction_type':'Purchase',product_id: 	product.id)
        if warranties_sale || warranties_purchase
          sale_array=[]
          purchase_array=[]
          warranties_sale.pluck(:serial).compact.uniq.map(&:upcase).each do |purchase|
            purchase.upcase.split("\r\n").each do |purch|
              sale_array << purch
            end
          end
          warranties_purchase.pluck(:serial).compact.uniq.map(&:upcase).each do |purchase|
            purchase.upcase.split("\r\n").each do |purch|
              purchase_array << purch
            end
          end
          list=String.new
          (purchase_array-sale_array).select{|s| list=s+' '+list}
          product.update(warranty_list: list.gsub(' ',"\r\n")[0...-2])
        end
      end
    end

    if type=="Purchase"
      respond_to do |format|
        format.html { redirect_to purchase_sale_details_path, notice: 'Purchase sale detail was successfully destroyed.' }
        format.json { head :no_content }
        format.js   { render :layout => false }
      end
    else
      respond_to do |format|
        format.html { redirect_to purchase_sale_details_path(sale: :true), notice: 'Purchase sale detail was successfully destroyed.' }
        format.json { head :no_content }
        format.js   { render :layout => false }
      end
    end
  end

  def return
    @created_at_gteq = DateTime.now
    @created_at_lteq = DateTime.now
    @item_types = ItemType.all
    @sys_users = SysUser.all
    @products=Product.all
    if params[:q].present?
      # @department = params[:q][:department_id]
      @created_at_gteq = params[:q][:created_at_gteq] if params[:q][:created_at_gteq].present?
      @created_at_lteq = params[:q][:created_at_lteq] if params[:q][:created_at_lteq].present?
      params[:q][:created_at_lteq] = params[:q][:created_at_lteq].to_date.end_of_day if params[:q][:created_at_lteq].present?
      @title = params[:q][:sys_user_id_eq]
      @code = params[:q][:credit_eq]
      @q = PurchaseSaleDetail.includes(:purchase_sale_items).joins(:purchase_sale_items).ransack(params[:q])
    else
      @q = PurchaseSaleDetail.includes(:purchase_sale_items).joins(:purchase_sale_items).ransack(params[:q])
    end
    @product_warranties_list = ProductWarranty.all
    @list_warranties=[]
    @product_warranties_list.pluck(:serial).uniq.each do |purchase|
      if purchase.present?
        purchase.split("\r\n").each do |purch|
          @list_warranties << purch
        end
      end
    end

    if @q.result.count > 0
      @q.sorts = 'id desc' if @q.sorts.empty?
    end
    @purchase_sale_details = @q.result.page(params[:page]).per(25)
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
    @q = PaperTrail::Version.where(item_id:PurchaseSaleDetail.where(transaction_type: params[:type]),item_type:'PurchaseSaleDetail').order('created_at desc').ransack(params[:q])
    @purchase_sale_logs = @q.result.page(params[:page])
    respond_to do |format|
      format.js
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_purchase_sale_detail
      @purchase_sale_detail = PurchaseSaleDetail.find(params[:id])
    end

    def user_type(id)
      SysUser.find(id).user_group
    end

    # Never trust parameters from the scary internet, only allow the white list through.
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
