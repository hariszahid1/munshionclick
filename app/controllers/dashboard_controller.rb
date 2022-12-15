class DashboardController < ApplicationController
  before_action :check_access
  def index
    redirect_to orders_path(sale: true) if current_user.salesman?
    @product_count=Product.count
    @sys_user_count=SysUser.count
    @total_sale_slips = PurchaseSaleDetail.where(transaction_type: "Sale").count
    @total_purchase_slips = PurchaseSaleDetail.where(transaction_type: "Purchase").count
    @total_expense_slips = ExpenseEntry.count
    @total_follow_ups = FollowUp.count
    @follow_up_count = FollowUp.where(created_at: Time.current.all_day).count
    @total_compaigns = Compaign.count
    @total_expense_today = ExpenseEntry.where(created_at: Time.current.all_day).count
    @total_expense_yesterday = ExpenseEntry.where(created_at: 1.day.ago.all_day).count
    @total_exp_today = ExpenseEntry.where(created_at: Time.current.all_day).sum(:amount)
    @total_exp_yesterday = ExpenseEntry.where(created_at: 1.day.ago.all_day).sum(:amount)
    @staff_count=Staff.count
    @transfer=Payment.where(confirmable: nil).count
    pos_setting = PosSetting.first
    if pos_setting.present?
      if pos_setting.expiry_date.present?
        if pos_setting.expiry_date<DateTime.now
          redirect_to destroy_user_session_path
          reset_session
        elsif (pos_setting.expiry_date-10.day)<DateTime.now

        end
      end
    end

    @due_advance = PropertyPlan.joins(:order).where(due_status:[nil, PropertyPlan.due_statuses["Unpaid"]]).where('due_date <= ?', Date.today).sum(:advance)
    @due_installment = PropertyInstallment.where(due_status:[nil, PropertyPlan.due_statuses["Unpaid"]]).where('due_date <= ?', Date.today).sum(:installment_price)

    @total_booked=Product.booked_plot.uniq
    @total_reserved=Product.secure_plot.uniq
    @total_remaning=Product.open_plot.uniq
    @total_only_booked=Product.only_booked_plot.uniq
    @total_transfer=Remark.where(remark_type:'Transfer')
    @total_orders = Order.count
    @q = Account.ransack(params[:q])
    @accounts=@q.result(distinct: true)
    if pos_type_batha
      @q = Product.ransack(params[:q])
    else
      @q = Product.where('stock>0').ransack(params[:q])
    end
    if @q.result.count > 0
      @q.sorts = ['item_type_id desc', 'title asc'] if @q.sorts.empty?
    end
    if params[:q].present?
      @title = params[:q][:item_type_title_or_title_or_code_cont]
      @code = params[:q][:title_cont]
      @item_type = params[:q][:item_type_cont]
    end
    @account_title =Account.all

    @today_credit = LedgerBook.where(created_at: DateTime.now.to_date.beginning_of_day..DateTime.now.to_date.end_of_day).sum(:credit)
    @today_debit = LedgerBook.where(created_at: DateTime.now.to_date.beginning_of_day..DateTime.now.to_date.end_of_day).sum(:debit)
    @customer_debit=LedgerBook.joins(:sys_user).where.not('sys_users.user_group': ["Both","Supplier"]).where(created_at: DateTime.now.to_date.beginning_of_day..DateTime.now.to_date.end_of_day).ransack().result.sum(:debit)
    @supplier_debit=LedgerBook.joins(:sys_user).where('sys_users.user_group': ["Both","Supplier"]).where(created_at: DateTime.now.to_date.beginning_of_day..DateTime.now.to_date.end_of_day).ransack().result.sum(:debit)
    @customer_credit=LedgerBook.joins(:sys_user).where.not('sys_users.user_group': ["Both","Supplier"]).where(created_at: DateTime.now.to_date.beginning_of_day..DateTime.now.to_date.end_of_day).ransack().result.sum(:credit)
    @supplier_credit=LedgerBook.joins(:sys_user).where('sys_users.user_group': ["Both","Supplier"]).where(created_at: DateTime.now.to_date.beginning_of_day..DateTime.now.to_date.end_of_day).ransack().result.sum(:credit)

    @t_credit = @customer_credit.to_f
    @t_debit  = @supplier_debit.to_f
    @sale_current_days = PurchaseSaleDetail.where('extract(year  from created_at) = ? AND extract(month  from created_at) = ? ',Date.current.year, Date.current.month).where(transaction_type: "Sale").group('(EXTRACT(YEAR FROM created_at))').group('(EXTRACT(MONTH FROM created_at))').group('(EXTRACT(DAY FROM created_at))').sum(:total_bill)
    @sale_current_month = PurchaseSaleDetail.where('extract(year  from created_at) = ? AND extract(month  from created_at) = ? ',Date.current.year, Date.current.month).where(transaction_type: "Sale").group('(EXTRACT(YEAR FROM created_at))').group('(EXTRACT(MONTH FROM created_at))').sum(:total_bill)
    @sale_year = PurchaseSaleDetail.where(transaction_type: "Sale").group('(EXTRACT(YEAR FROM created_at))').sum(:total_bill)

    @purchase_current_days = PurchaseSaleDetail.where('extract(year  from created_at) = ? AND extract(month  from created_at) = ? ',Date.current.year, Date.current.month).where(transaction_type: "Purchase").group('(EXTRACT(YEAR FROM created_at))').group('(EXTRACT(MONTH FROM created_at))').group('(EXTRACT(DAY FROM created_at))').sum(:total_bill)
    @purchase_current_month = PurchaseSaleDetail.where('extract(year  from created_at) = ? AND extract(month  from created_at) = ? ',Date.current.year, Date.current.month).where(transaction_type: "Purchase").group('(EXTRACT(YEAR FROM created_at))').group('(EXTRACT(MONTH FROM created_at))').sum(:total_bill)
    @purchase_year = PurchaseSaleDetail.where(transaction_type: "Purchase").group('(EXTRACT(YEAR FROM created_at))').sum(:total_bill)

    @pathair_kachi_day = DailyBook.joins(:salary_details).where(daily_books: {department_id: 1}).where('extract(year  from salary_details.created_at) = ? AND extract(month  from salary_details.created_at) = ? ',Date.current.year, Date.current.month).group('(EXTRACT(YEAR FROM salary_details.created_at))').group('(EXTRACT(MONTH FROM salary_details.created_at))').group('(EXTRACT(DAY FROM salary_details.created_at))').sum('salary_details.raw_quantity')
    @pathair_kachi_month = DailyBook.joins(:salary_details).where(daily_books: {department_id: 1}).where('extract(year  from salary_details.created_at) = ? AND extract(month  from salary_details.created_at) = ? ',Date.current.year, Date.current.month).group('(EXTRACT(YEAR FROM salary_details.created_at))').group('(EXTRACT(MONTH FROM salary_details.created_at))').sum('salary_details.raw_quantity')
    @pathair_kachi_year = DailyBook.joins(:salary_details).where(daily_books: {department_id: 1}).group('(EXTRACT(YEAR FROM salary_details.created_at))').sum('salary_details.raw_quantity')

    @khakar_kachi_day = DailyBook.joins(:salary_details).where(daily_books: {department_id: 2}).where('extract(year  from salary_details.created_at) = ? AND extract(month  from salary_details.created_at) = ? ',Date.current.year, Date.current.month).group('(EXTRACT(YEAR FROM salary_details.created_at))').group('(EXTRACT(MONTH FROM salary_details.created_at))').group('(EXTRACT(DAY FROM salary_details.created_at))').sum('salary_details.khakar_quanity')
    @khakar_kachi_month = DailyBook.joins(:salary_details).where(daily_books: {department_id: 2}).where('extract(year  from salary_details.created_at) = ? AND extract(month  from salary_details.created_at) = ? ',Date.current.year, Date.current.month).group('(EXTRACT(YEAR FROM salary_details.created_at))').group('(EXTRACT(MONTH FROM salary_details.created_at))').sum('salary_details.khakar_quanity')
    @khakar_kachi_year = DailyBook.joins(:salary_details).where(daily_books: {department_id: 2}).group('(EXTRACT(YEAR FROM salary_details.created_at))').sum('salary_details.khakar_quanity')






    @items =Product.where('stock>0')
    @products = @q.result(distinct: true).page(params[:page])
    @total_stock = @items.sum(:stock)
    @total_cprice = @items.sum('stock*cost')
    @total_sprice = @items.sum('stock*sale')
    @payable=SysUser.where('balance > 0').pluck('balance').map(&:abs).sum
    @receivable = SysUser.where('(balance < 0)').pluck('balance').map(&:abs).sum






    @book_date_gteq = Date.today.prev_occurring(:thursday)
    @boot_d =Date.yesterday
    @boot_today =Date.today
    @book_date_lteq = DateTime.now
    @total_sale=PurchaseSaleDetail.where(created_at: @boot_d.to_date.beginning_of_day..@boot_d.to_date.end_of_day ,:transaction_type=>"Sale").sum(:total_bill)
    @total_receipt=PurchaseSaleDetail.where(created_at: @boot_d.to_date.beginning_of_day..@boot_d.to_date.end_of_day ,:transaction_type=>"Sale").count()
    @total_sale_today=PurchaseSaleDetail.where(created_at: @boot_today.to_date.beginning_of_day..@boot_today.to_date.end_of_day ,:transaction_type=>"Sale").sum(:total_bill)
    @total_receipt_today=PurchaseSaleDetail.where(created_at: @boot_today.to_date.beginning_of_day..@boot_today.to_date.end_of_day ,:transaction_type=>"Sale").count()

    @total_purchase=PurchaseSaleDetail.where(created_at: @boot_d.to_date.beginning_of_day..@boot_d.to_date.end_of_day ,:transaction_type=>"Purchase").sum(:total_bill)
    @total_purchase_receipt=PurchaseSaleDetail.where(created_at: @boot_d.to_date.beginning_of_day..@boot_d.to_date.end_of_day ,:transaction_type=>"Purchase").count()
    @total_purchase_today=PurchaseSaleDetail.where(created_at: @boot_today.to_date.beginning_of_day..@boot_today.to_date.end_of_day ,:transaction_type=>"Purchase").sum(:total_bill)
    @total_purchase_receipt_today=PurchaseSaleDetail.where(created_at: @boot_today.to_date.beginning_of_day..@boot_today.to_date.end_of_day ,:transaction_type=>"Purchase").count()




    if @pos_type_batha=pos_type_batha




      @departments=Department.all
      @raw_products = RawProduct.all
      if params[:q].present?
        @department = params[:q][:department_id]
        @book_date_gteq = params[:q][:book_date_gteq] if params[:q][:book_date_gteq].present?
        @book_date_lteq = params[:q][:book_date_lteq] if params[:q][:book_date_lteq].present?
      end

      @s = DailyBook.includes(:salary_details).where(book_date: @book_date_gteq.to_date.beginning_of_day..@book_date_lteq.to_date.end_of_day,department_id: @departments.first.id).ransack()
      @k = DailyBook.includes(:salary_details).where(created_at: @book_date_gteq.to_date.beginning_of_day..@book_date_lteq.to_date.end_of_day,department_id: @departments.second.id).ransack()
      @p = ProductionCycle.includes(:production_blocks).where('production_blocks.date': @book_date_gteq.to_date.beginning_of_day..@book_date_lteq.to_date.end_of_day,status:"bhari").ransack()
      @j = ProductionCycle.includes(:production_blocks).where('production_blocks.date': @book_date_gteq.to_date.beginning_of_day..@book_date_lteq.to_date.end_of_day,status:"jalai").ransack()
      @n = ProductionCycle.joins(:production_blocks).where(start_date: @book_date_gteq.to_date.beginning_of_day..@book_date_lteq.to_date.end_of_day,status:"nakasi").ransack()

      if @s.result.count > 0
        @s.sorts = 'id desc' if @s.sorts.empty?
      end
      if @j.result.count > 0
        @j.sorts = 'date desc' if @j.sorts.empty?
      end

      if @q.result.count > 0
        @q.sorts = 'book_date desc' if @q.sorts.empty?
      end
      if @k.result.count > 0
        @k.sorts = 'created_at desc' if @k.sorts.empty?
      end
      if @n.result.count > 0
        @n.sorts = 'date desc' if @n.sorts.empty?
      end

      @daily_books = @s.result
      @khakar_daily_books = @k.result
      @production_cycles = @p.result
      @jalai_production_cycles = @j.result(distinct: true)
      @nkasi_production_cycles = @n.result(distinct: true)


      #Pather Sum Data
      @daily_book_salary_details_raw_quantity = @daily_books.sum('salary_details.raw_quantity')
      @daily_book_salary_details_f99_raw_quantity = @daily_books.where('salary_details.raw_product_id': RawProduct.first).sum('salary_details.raw_quantity')
      @daily_book_salary_details_tile_raw_quantity = @daily_books.where('salary_details.raw_product_id': RawProduct.second).sum('salary_details.raw_quantity')
      @daily_book_salary_details_f99_quantity = @daily_books.where('salary_details.raw_product_id': RawProduct.first).sum('salary_details.quantity')
      @daily_book_salary_details_tile_quantity = @daily_books.where('salary_details.raw_product_id': RawProduct.second).sum('salary_details.quantity')
      @daily_book_salary_details_quantity = @daily_books.sum('salary_details.quantity')

      #Kharkar Sum Data
      @salary_details_khakar_quantity_from_pather =  @khakar_daily_books.where.not('salary_details.staff_pathera_id': nil).pluck(:khakar_quanity)
      @salary_details_khakar_quantity_from_stock = @khakar_daily_books.where('salary_details.staff_pathera_id': nil).pluck(:khakar_quanity)
      @salary_details_khakar_f99_raw_quantity=@khakar_daily_books.where('salary_details.raw_product_id': RawProduct.first).pluck(:khakar_quanity)
      @salary_details_khakar_tile_raw_quantity=@khakar_daily_books.where('salary_details.raw_product_id': RawProduct.second).pluck(:khakar_quanity)
      @daily_book_salary_details_khakar_raw_quantity=@khakar_daily_books.pluck(:khakar_quanity)
      @daily_book_salary_details_khakar_quantity=@khakar_daily_books.sum(:khakar_quanity)
      @salary_details_pather_remaning_quanity_bhari=@khakar_daily_books.where('salary_details.transaction_location': :bhari).pluck(:khakar_remaning)
      @salary_details_pather_remaning_quanity_stock=@khakar_daily_books.where('salary_details.transaction_location': :bhari).pluck(:khakar_remaning)
      @salary_details_pather_remaning_quanity_chapa=@khakar_daily_books.where('salary_details.transaction_location': :bhari).pluck(:khakar_remaning)
      @daily_book_salary_details_quantity_rate=@khakar_daily_books.pluck(:khakar_wast)

      #bhari Sum Data
      @production_blocks_bricks_quantity = @production_cycles.sum('production_blocks.bricks_quantity')
      @production_blocks_tiles_quantity  = @production_cycles.sum('production_blocks.tiles_quantity')
      @production_blocks_chamber  = @production_cycles.count('production_blocks.id')

      #jalai Sum Data
      @lines=@jalai_production_cycles.sum(:lines).to_i

      @total_bricks=@jalai_production_cycles.sum(:total_bricks).to_i

      @total_cost=@jalai_production_cycles.sum(:total_cost).to_f.round(2)

      @cost_per_line=@jalai_production_cycles.sum(:cost_per_line).to_f.round(2)

      @per_thousand_product_cost=@jalai_production_cycles.sum(:per_thousand_product_cost).to_f.round(2)

      @per_product_cost=@jalai_production_cycles.sum(:per_product_cost).to_f.round(2)

      @total_item_quantity=@jalai_production_cycles.sum(:total_item_quantity).to_f.round(2)

      @item_quantity_per_line=@jalai_production_cycles.sum(:item_quantity_per_line).to_f.round(2)

      @per_ton_bricks=@jalai_production_cycles.sum(:per_ton_bricks).to_f.round(2)

      (@total_item_quantity/@total_bricks).to_f.round(2)

      #nakasi Sum Data
    end
    #  @revenue=Hash.new
    #  (1..12).each do |i|
      #  @paid_to_month == 0 ? @paid_to_month = 12 : @paid_to_month
    #    @revenue[Date::ABBR_MONTHNAMES[@paid_to_month.to_f]] =
    #    DailyBook.where("extract(month from created_at)=? AND extract(year from created_at) = ?",@paid_to_month, @paid_to_year).where(department_id: @departments.first.id).RawProduct.sum(:raw_quantity)
    #    @paid_to_month = @paid_to_month - 1
    #    @paid_to_month == 0 ? @paid_to_year = @paid_to_year-1 : @paid_to_year
    #  end
    #  @revenue=@revenue.to_a.reverse.to_h
    #  if params[:from].present?
    #    @paid_to_month = params[:from][:month].present? ? params[:from][:month].to_i : Date.today.month
    #    @paid_to_year =  params[:from][:year].present? ? params[:from][:year].to_i : Date.today.year
    #  else
    #    @paid_to_month = Date.today.month
    #    @paid_to_year = Date.today.year
    #  end



    if params[:pdf_submit].present?
      @q = Product.where('stock>0').ransack(params[:q])
      if @q.result.count > 0
        @q.sorts = ['item_type_id desc', 'title asc'] if @q.sorts.empty?
      end
      @products = @q.result
      @products_sale_total =  PurchaseSaleItem.where(transaction_type: "Purchase").sum(:total_cost_price)
      request.format = 'pdf'
      respond_to do |format|
        format.html
        format.pdf do
          @pos_setting=PosSetting.first
          render pdf: "Day-Out",
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
    elsif params[:mobile_pdf_submit].present?
      @q = Product.where('stock>0').ransack(params[:q])
      if @q.result.count > 0
        @q.sorts = ['item_type_id asc', 'title asc'] if @q.sorts.empty?
      end
      @products = @q.result
      @products_sale_total =  PurchaseSaleItem.where(transaction_type: "Purchase").sum(:total_cost_price)
      request.format = 'pdf'
      respond_to do |format|
        format.html
        format.pdf do
          @pos_setting=PosSetting.first
          render pdf: "index_mobile",
          layout: 'index_mobile.pdf',
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

    respond_to do |format|
      format.js
      format.pdf
      format.html
    end

  end

  def export
    company_name = RequestStore.store[:company_type]
    %x[rake db:backup[#{company_name}]]
    redirect_to dashboard_path, notice: 'Backup Store on Server'
  end

  def stock_by_category
    if params[:daily_sales].present?
      @paid_to_day = Date.today.day
      @paid_to_month = params[:daily_sales][:month]
      @paid_to_year = params[:daily_sales][:year]
      @lastday=Time.days_in_month(@paid_to_month.to_i, @paid_to_year.to_i)
    else
      @paid_to_day = Date.today.day
      @paid_to_month = Date.today.month
      @paid_to_year = Date.today.year
      @lastday=Time.days_in_month(@paid_to_month, @paid_to_year)
    end
    @q=Product.ransack()
    @products = @q.result(distinct: true)
    @stock_report=Hash.new
    @stock_by_category=Product.group(:item_type_id,:product_category_id,:product_sub_category_id).sum(:stock)
    @stock_by_category.each_with_index do |product,index|
      @stock_report[index]=
      product.first.first.present? ? ItemType.find(product.first.first).title : '',
      product.first.second.present? ? ProductCategory.find(product.first.second).title : '',
      product.first.third.present? ? ProductSubCategory.find(product.first.third).title : '',
      product.last,
      PurchaseSaleItem.where("extract(month from created_at)=? AND extract(year from created_at)=?",@paid_to_month,@paid_to_year).where(product_id: Product.where(item_type_id:product.first.first,product_category_id:product.first.second,product_sub_category_id:product.first.third).pluck(:id),transaction_type: "Purchase").sum(:quantity),
      PurchaseSaleItem.where("extract(month from created_at)=? AND extract(year from created_at)=?",@paid_to_month,@paid_to_year).where(product_id: Product.where(item_type_id:product.first.first,product_category_id:product.first.second,product_sub_category_id:product.first.third).pluck(:id),transaction_type: "Sale").sum(:quantity)
    end
  end
  def raw_material
    @q = Item.ransack(params[:q])
    if @q.result.count > 0
      @q.sorts = 'id asc' if @q.sorts.empty?
    end
    if params[:q].present?
      @title = params[:q][:title_cont]
      @code = params[:q][:code_cont]
    end
    @items = @q.result(distinct: true).page(params[:page])

  end

end
