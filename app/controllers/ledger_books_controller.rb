class LedgerBooksController < ApplicationController
	include LedgerBooksCsvMethods
  before_action :set_ledger_book, only: [:show, :edit, :update, :destroy]

  # GET /ledger_books
  # GET /ledger_books.json
  def index
    @pos_setting = PosSetting.last
    @created_at_gteq = Date.today.beginning_of_year
    @created_at_lteq = DateTime.now
    if params[:q].present?
      if params[:q][:sys_user_id_eq].present?
        @sys_user=SysUser.find(params[:q][:sys_user_id_eq])
      else
        @sys_user=SysUser.new(created_at:DateTime.now,opening_balance:0)
      end
    end
    if params[:q].present?
      @department = params[:q][:department_id]
      @created_at_gteq = params[:q][:created_at_gteq] if params[:q][:created_at_gteq].present?
      @created_at_lteq = params[:q][:created_at_lteq] if params[:q][:created_at_lteq].present?
      params[:q][:created_at_lteq] = params[:q][:created_at_lteq].to_date.end_of_day if params[:q][:created_at_lteq].present?
      @title = params[:q][:sys_user_id_eq]
      @code = params[:q][:credit_eq]
      @q = LedgerBook.ransack(params[:q])
    else
      @sys_user=SysUser.new(opening_balance:0)
      @q = LedgerBook.where(created_at: @created_at_gteq.to_date.beginning_of_day..@created_at_lteq.to_date.end_of_day).ransack()
    end

    @ledger_searchs=SysUser.all
    #@purchase_sale_details = @p.result
    @ledger_books = @q.result.page(params[:page])
    @ledger_books_all = @ledger_books.select('SUM(debit) as sum_debit','SUM(credit) as sum_credit','SUM(credit)-SUM(debit) as mean_sum')
    @customers=SysUser.all

		
    if params[:submit_pdf].present? or params[:submit_pdf_without].present? or params[:desc_email].present? or params[:submit_pdf_short].present? or params[:submit_csv_without].present? or params[:submit_csv].present?
      @sys_users = SysUser.all
      sys_user_id = params[:q][:sys_user_id_eq].present? ? params[:q][:sys_user_id_eq] : @sys_users
      @products_sale = PurchaseSaleDetail.joins(purchase_sale_items: :product).where(transaction_type: "Sale",'purchase_sale_items.purchase_sale_type':"Sale_type").where(sys_user_id: sys_user_id, created_at: @created_at_gteq.to_date.beginning_of_day..@created_at_lteq.to_date.end_of_day,transaction_type: "Sale").group(:title).sum(:total_sale_price)
      @products_count = PurchaseSaleDetail.joins(purchase_sale_items: :product).where(transaction_type: "Sale",'purchase_sale_items.purchase_sale_type':"Sale_type").where(sys_user_id: sys_user_id, created_at: @created_at_gteq.to_date.beginning_of_day..@created_at_lteq.to_date.end_of_day,transaction_type: "Sale").group(:title).sum('purchase_sale_items.quantity')

      @products_sale_return = PurchaseSaleDetail.joins(purchase_sale_items: :product).where(transaction_type: "Sale",'purchase_sale_items.purchase_sale_type':"Return_type").where(sys_user_id: sys_user_id, created_at: @created_at_gteq.to_date.beginning_of_day..@created_at_lteq.to_date.end_of_day,transaction_type: "Sale").group(:title).sum(:total_sale_price)
      @products_count_return = PurchaseSaleDetail.joins(purchase_sale_items: :product).where(transaction_type: "Sale",'purchase_sale_items.purchase_sale_type':"Return_type").where(sys_user_id: sys_user_id, created_at: @created_at_gteq.to_date.beginning_of_day..@created_at_lteq.to_date.end_of_day,transaction_type: "Sale").group(:title).sum('purchase_sale_items.quantity')

      @products_sale_total = PurchaseSaleDetail.joins(purchase_sale_items: :product).where(transaction_type: "Sale",'purchase_sale_items.purchase_sale_type':"Sale_type").where(sys_user_id: sys_user_id, created_at: @created_at_gteq.to_date.beginning_of_day..@created_at_lteq.to_date.end_of_day,transaction_type: "Sale").sum(:total_sale_price)
      @products_purchase_count = PurchaseSaleDetail.joins(purchase_sale_items: :product).where(transaction_type: "Purchase").where(sys_user_id: sys_user_id, created_at: @created_at_gteq.to_date.beginning_of_day..@created_at_lteq.to_date.end_of_day,transaction_type: "Purchase").group(:title).sum('purchase_sale_items.quantity')

      @product_carriage = PurchaseSaleDetail.where(sys_user_id: sys_user_id,created_at: @created_at_gteq.to_date.beginning_of_day..@created_at_lteq.to_date.end_of_day,transaction_type: "Sale").sum(:carriage)
      @product_loading = PurchaseSaleDetail.where(sys_user_id: sys_user_id,created_at: @created_at_gteq.to_date.beginning_of_day..@created_at_lteq.to_date.end_of_day,transaction_type: "Sale").sum(:loading)
      if @q.result.count > 0
        @q.sorts = ['created_at desc', 'id desc']
      end

      if params[:desc_email].present?
        @pos_setting=PosSetting.first
        @ledger_books_pdf=@q.result
        @pdf_index=render_to_string(:pdf => "Desc - Ledger book",:template => 'ledger_books/index.pdf.erb',:filename => 'Desc - Ledger book')
      else
        @ledger_books_pdf=@q.result
        request.format = 'pdf'
      end
			# submit_csv_without
			if params[:submit_csv_without].present? or params[:submit_csv].present?
				@ledger_books_csv=@q.result(distinct: true)
				createCSV
			else

				print_pdf('User LedgerBook -'+@created_at_gteq.to_s+' to '+@created_at_lteq.to_s,'pdf.html','A4')
				
			end
# 2nd if
    elsif params[:submit_form].present? or params[:submit_form_without].present? or params[:asc_email].present? or params[:submit_form_without_csv].present? or params[:submit_form_csv].present?
      @sys_users = SysUser.all
      sys_user_id = params[:q][:sys_user_id_eq].present? ? params[:q][:sys_user_id_eq] : @sys_users
      @products_sale = PurchaseSaleDetail.joins(purchase_sale_items: :product).where(transaction_type: "Sale",'purchase_sale_items.purchase_sale_type':"Sale_type").where(sys_user_id: sys_user_id, created_at: @created_at_gteq.to_date.beginning_of_day..@created_at_lteq.to_date.end_of_day,transaction_type: "Sale").group(:title).sum(:total_sale_price)
      @products_count = PurchaseSaleDetail.joins(purchase_sale_items: :product).where(transaction_type: "Sale",'purchase_sale_items.purchase_sale_type':"Sale_type").where(sys_user_id: sys_user_id, created_at: @created_at_gteq.to_date.beginning_of_day..@created_at_lteq.to_date.end_of_day,transaction_type: "Sale").group(:title).sum('purchase_sale_items.quantity')

      @products_sale_return = PurchaseSaleDetail.joins(purchase_sale_items: :product).where(transaction_type: "Sale",'purchase_sale_items.purchase_sale_type':"Return_type").where(sys_user_id: sys_user_id, created_at: @created_at_gteq.to_date.beginning_of_day..@created_at_lteq.to_date.end_of_day,transaction_type: "Sale").group(:title).sum(:total_sale_price)
      @products_count_return = PurchaseSaleDetail.joins(purchase_sale_items: :product).where(transaction_type: "Sale",'purchase_sale_items.purchase_sale_type':"Return_type").where(sys_user_id: sys_user_id, created_at: @created_at_gteq.to_date.beginning_of_day..@created_at_lteq.to_date.end_of_day,transaction_type: "Sale").group(:title).sum('purchase_sale_items.quantity')

      @products_purchase_count = PurchaseSaleDetail.joins(purchase_sale_items: :product).where(transaction_type: "Purchase").where(sys_user_id: sys_user_id, created_at: @created_at_gteq.to_date.beginning_of_day..@created_at_lteq.to_date.end_of_day,transaction_type: "Purchase").group(:title).sum('purchase_sale_items.quantity')
      @products_purchase_count_return = PurchaseSaleDetail.joins(purchase_sale_items: :product).where(transaction_type: "Purchase",'purchase_sale_items.purchase_sale_type':"Return_type").where(sys_user_id: sys_user_id, created_at: @created_at_gteq.to_date.beginning_of_day..@created_at_lteq.to_date.end_of_day,transaction_type: "Purchase").group(:title).sum('purchase_sale_items.quantity')
      @products_sale_total = PurchaseSaleDetail.joins(purchase_sale_items: :product).where(transaction_type: "Sale").where(sys_user_id: sys_user_id, created_at: @created_at_gteq.to_date.beginning_of_day..@created_at_lteq.to_date.end_of_day,transaction_type: "Sale").sum(:total_sale_price)


      @product_carriage = PurchaseSaleDetail.where(sys_user_id: sys_user_id,created_at: @created_at_gteq.to_date.beginning_of_day..@created_at_lteq.to_date.end_of_day,transaction_type: "Sale").sum(:carriage)
      @product_loading = PurchaseSaleDetail.where(sys_user_id: sys_user_id,created_at: @created_at_gteq.to_date.beginning_of_day..@created_at_lteq.to_date.end_of_day,transaction_type: "Sale").sum(:loading)

      if @q.result.count > 0
        @q.sorts = ['created_at asc', 'id asc']
      end
      if params[:asc_email].present?
        @pos_setting=PosSetting.first
        @ledger_books_pdf=@q.result
        @pdf_index=render_to_string(:pdf => "Asc - Ledger book",:template => 'ledger_books/index.pdf.erb',:filename => 'Asc - Ledger book')
      else
        @ledger_books_pdf=@q.result
        request.format = 'pdf'
      end
			# pdf and csv
			if params[:submit_form_without_csv].present? or params[:submit_form_csv].present?
				@ledger_books_csv=@q.result(distinct: true)
				createCSV
			else
				print_pdf('User LedgerBook -'+@created_at_gteq.to_s+' to '+@created_at_lteq.to_s,'pdf.html','A4')
			end
    elsif params[:submit_debit].present? or params[:submit_debit_csv].present?
      @debit=true
      if params[:q].present?
        @customer_debit = LedgerBook.joins(:sys_user).where.not('sys_users.user_group': ["Both","Supplier"]).where('debit>0').ransack(params[:q]).result.group('sys_users.name').sum(:debit)
        @supplier_debit = LedgerBook.joins(:sys_user).where('sys_users.user_group': ["Both","Supplier"]).where('debit>0').ransack(params[:q]).result.group('sys_users.name').sum(:debit)
        @customer_credit = LedgerBook.joins(:sys_user).where.not('sys_users.user_group': ["Both","Supplier"]).where(created_at: @created_at_gteq.to_date.beginning_of_day..@created_at_lteq.to_date.end_of_day).where('credit>0').ransack(params[:q]).result.group('sys_users.name').sum(:credit)
        @supplier_credit = LedgerBook.joins(:sys_user).where('sys_users.user_group': ["Both","Supplier"]).where(created_at: @created_at_gteq.to_date.beginning_of_day..@created_at_lteq.to_date.end_of_day).where('credit>0').ransack(params[:q]).result.group('sys_users.name').sum(:credit)

        @order_customer_credit = Order.joins(:sys_user).where.not('sys_users.user_group': ["Both","Supplier"]).where(created_at: @created_at_gteq.to_date.beginning_of_day..@created_at_lteq.to_date.end_of_day).where('amount>0').ransack().result.group('sys_users.name').sum(:amount)
        @sale_customer_credit = PurchaseSaleDetail.joins(:sys_user).where.not('sys_users.user_group': ["Both","Supplier"]).where(created_at: @created_at_gteq.to_date.beginning_of_day..@created_at_lteq.to_date.end_of_day).where('amount>0').ransack().result.group('sys_users.name').sum(:amount)

        @customer_debit_date = LedgerBook.joins(:sys_user).where.not('sys_users.user_group': ["Both","Supplier"]).where('debit>0').ransack(params[:q]).result.group('sys_users.name','created_at').sum(:debit)
        @supplier_debit_date = LedgerBook.joins(:sys_user).where('sys_users.user_group': ["Both","Supplier"]).where('debit>0').ransack(params[:q]).result.group('sys_users.name','created_at').sum(:debit)
        @customer_credit_date = LedgerBook.joins(:sys_user).where.not('sys_users.user_group': ["Both","Supplier"]).where(created_at: @created_at_gteq.to_date.beginning_of_day..@created_at_lteq.to_date.end_of_day).where('credit>0').ransack(params[:q]).result.group('sys_users.name','created_at').sum(:credit)
        @supplier_credit_date = LedgerBook.joins(:sys_user).where('sys_users.user_group': ["Both","Supplier"]).where(created_at: @created_at_gteq.to_date.beginning_of_day..@created_at_lteq.to_date.end_of_day).where('credit>0').ransack(params[:q]).result.group('sys_users.name','created_at').sum(:credit)

        @account_credit = Payment.joins(:account).where(paymentable_type:['PurchaseSaleDetail','Order','LedgerBook'],created_at: @created_at_gteq.to_date.beginning_of_day..@created_at_lteq.to_date.end_of_day).group('accounts.title').sum(:credit)
        @account_debit = Payment.joins(:account).where(paymentable_type:['PurchaseSaleDetail','Order','LedgerBook'],created_at: @created_at_gteq.to_date.beginning_of_day..@created_at_lteq.to_date.end_of_day).group('accounts.title').sum(:debit)
      else
        @customer_debit=LedgerBook.joins(:sys_user).where.not('sys_users.user_group': ["Both","Supplier"]).where(created_at: @created_at_gteq.to_date.beginning_of_day..@created_at_lteq.to_date.end_of_day).where('debit>0').ransack().result.group('sys_users.name').sum(:debit)
        @supplier_debit=LedgerBook.joins(:sys_user).where('sys_users.user_group': ["Both","Supplier"]).where(created_at: @created_at_gteq.to_date.beginning_of_day..@created_at_lteq.to_date.end_of_day).where('debit>0').ransack().result.group('sys_users.name').sum(:debit)
        @customer_credit=LedgerBook.joins(:sys_user).where.not('sys_users.user_group': ["Both","Supplier"]).where('credit>0').ransack(params[:q]).result.group('sys_users.name').sum(:credit)
        @supplier_credit=LedgerBook.joins(:sys_user).where('sys_users.user_group': ["Both","Supplier"]).where('credit>0').ransack(params[:q]).result.group('sys_users.name').sum(:credit)

        @customer_debit=LedgerBook.joins(:sys_user).where.not('sys_users.user_group': ["Both","Supplier"]).where(created_at: @created_at_gteq.to_date.beginning_of_day..@created_at_lteq.to_date.end_of_day).where('debit>0').ransack().result.group('sys_users.name','created_at').sum(:debit)
        @supplier_debit=LedgerBook.joins(:sys_user).where('sys_users.user_group': ["Both","Supplier"]).where(created_at: @created_at_gteq.to_date.beginning_of_day..@created_at_lteq.to_date.end_of_day).where('debit>0').ransack().result.group('sys_users.name','created_at').sum(:debit)
        @customer_credit=LedgerBook.joins(:sys_user).where.not('sys_users.user_group': ["Both","Supplier"]).where('credit>0').ransack().result.group('sys_users.name','created_at').sum(:credit)
        @supplier_credit=LedgerBook.joins(:sys_user).where('sys_users.user_group': ["Both","Supplier"]).where('credit>0').ransack().result.group('sys_users.name','created_at').sum(:credit)

        @account_credit = Payment.joins(:account).where(paymentable_type:['PurchaseSaleDetail','Order','LedgerBook'],created_at: @created_at_gteq.to_date.beginning_of_day..@created_at_lteq.to_date.end_of_day).group('accounts.title').sum(:credit)
        @account_debit = Payment.joins(:account).where(paymentable_type:['PurchaseSaleDetail','Order','LedgerBook'],created_at: @created_at_gteq.to_date.beginning_of_day..@created_at_lteq.to_date.end_of_day).group('accounts.title').sum(:debit)
      end
			if params[:submit_debit_csv].present?
				csv_data = debit_csv
				request.format = 'csv'
				respond_to do |format|
				format.html
				format.csv { send_data csv_data, filename: "Users - #{Date.today}.csv" }
				end
			else
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
      
    elsif params[:submit_credit].present? or params[:submit_credit_csv].present?
      if params[:q].present?
        @customer_debit=LedgerBook.joins(:sys_user).where.not('sys_users.user_group': ["Both","Supplier"]).where('debit>0').ransack(params[:q]).result.group('sys_users.name').sum(:debit)
        @supplier_debit=LedgerBook.joins(:sys_user).where('sys_users.user_group': ["Both","Supplier"]).where('debit>0').ransack(params[:q]).result.group('sys_users.name').sum(:debit)
        @customer_credit=LedgerBook.joins(:sys_user).where.not('sys_users.user_group': ["Both","Supplier"]).where(created_at: @created_at_gteq.to_date.beginning_of_day..@created_at_lteq.to_date.end_of_day).where('credit>0').ransack(params[:q]).result.group('sys_users.name').sum(:credit)
        @supplier_credit=LedgerBook.joins(:sys_user).where('sys_users.user_group': ["Both","Supplier"]).where(created_at: @created_at_gteq.to_date.beginning_of_day..@created_at_lteq.to_date.end_of_day).where('credit>0').ransack(params[:q]).result.group('sys_users.name').sum(:credit)
        @credit=LedgerBook.joins(:sys_user).ransack(params[:q]).result.group('sys_users.name').sum(:credit)

        @customer_debit_date=LedgerBook.joins(:sys_user).where.not('sys_users.user_group': ["Both","Supplier"]).where('debit>0').ransack(params[:q]).result.group('sys_users.name','created_at').sum(:debit)
        @supplier_debit_date=LedgerBook.joins(:sys_user).where('sys_users.user_group': ["Both","Supplier"]).where('debit>0').ransack(params[:q]).result.group('sys_users.name','created_at').sum(:debit)
        @customer_credit_date=LedgerBook.joins(:sys_user).where.not('sys_users.user_group': ["Both","Supplier"]).where(created_at: @created_at_gteq.to_date.beginning_of_day..@created_at_lteq.to_date.end_of_day).where('credit>0').ransack(params[:q]).result.group('sys_users.name','created_at').sum(:credit)
        @supplier_credit_date=LedgerBook.joins(:sys_user).where('sys_users.user_group': ["Both","Supplier"]).where(created_at: @created_at_gteq.to_date.beginning_of_day..@created_at_lteq.to_date.end_of_day).where('credit>0').ransack(params[:q]).result.group('sys_users.name','created_at').sum(:credit)

      else
        @customer_debit=LedgerBook.joins(:sys_user).where.not('sys_users.user_group': ["Both","Supplier"]).where(created_at: @created_at_gteq.to_date.beginning_of_day..@created_at_lteq.to_date.end_of_day).where('debit>0').ransack().result.group('sys_users.name').sum(:debit)
        @supplier_debit=LedgerBook.joins(:sys_user).where('sys_users.user_group': ["Both","Supplier"]).where(created_at: @created_at_gteq.to_date.beginning_of_day..@created_at_lteq.to_date.end_of_day).where('debit>0').ransack().result.group('sys_users.name').sum(:debit)
        @customer_credit=LedgerBook.joins(:sys_user).where.not('sys_users.user_group': ["Both","Supplier"]).where('credit>0').ransack().result.group('sys_users.name').sum(:credit)
        @supplier_credit=LedgerBook.joins(:sys_user).where('sys_users.user_group': ["Both","Supplier"]).where('credit>0').ransack().result.group('sys_users.name').sum(:credit)
        @credit=LedgerBook.joins(:sys_user).where(created_at: @created_at_gteq.to_date.beginning_of_day..@created_at_lteq.to_date.end_of_day).ransack().result.group('sys_users.name').sum(:credit)

        @customer_debit_date=LedgerBook.joins(:sys_user).where.not('sys_users.user_group': ["Both","Supplier"]).where(created_at: @created_at_gteq.to_date.beginning_of_day..@created_at_lteq.to_date.end_of_day).where('debit>0').ransack().result.group('sys_users.name','created_at').sum(:debit)
        @supplier_debit_date=LedgerBook.joins(:sys_user).where('sys_users.user_group': ["Both","Supplier"]).where(created_at: @created_at_gteq.to_date.beginning_of_day..@created_at_lteq.to_date.end_of_day).where('debit>0').ransack().result.group('sys_users.name','created_at').sum(:debit)
        @customer_credit_date=LedgerBook.joins(:sys_user).where.not('sys_users.user_group': ["Both","Supplier"]).where('credit>0').ransack().result.group('sys_users.name','created_at').sum(:credit)
        @supplier_credit_date=LedgerBook.joins(:sys_user).where('sys_users.user_group': ["Both","Supplier"]).where('credit>0').ransack().result.group('sys_users.name','created_at').sum(:credit)
      end
			if params[:submit_credit_csv].present?
				csv_data = credit_csv
				request.format = 'csv'
				respond_to do |format|
				format.html
				format.csv { send_data csv_data, filename: "Users - #{Date.today}.csv" }
				end
			else
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

    if @q.result.count > 0
      @q.sorts = ['created_at desc', 'id desc'] if @q.sorts.empty?
    end
    @ledger_books = @q.result.page(params[:page])

    if params[:desc_email].present? or params[:asc_email].present?
      @pos_setting=PosSetting.first
      subject = "#{@pos_setting.display_name} - Ledger book"
      email = current_user.superAdmin.email_to.present? ? current_user.superAdmin.email_to : "info@munshionclick.com"
      pdf=[[@pdf_index,'Ledger_book']]
      ReportMailer.new_report_email(pdf,subject,email,"").deliver
      return redirect_to ledger_books_path
    end

    @ledger_books_credit = @q.result.sum(:credit)
    @ledger_books_debit = @q.result.sum(:debit)

  end

  # GET /ledger_books/1
  # GET /ledger_books/1.json
  def show
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

  # GET /ledger_books/new
  def new
    @suppliers=SysUser.all
    @customers=SysUser.where.not(:user_group=>['Supplier','Both'])
    @ledger_book = LedgerBook.new
    @accounts=Account.all
    @account=current_user.user_account
  end

  # GET /ledger_books/1/edit
  def edit
    @customers=SysUser.all
    @accounts=Account.all
  end

  # POST /ledger_books
  # POST /ledger_books.json
  def create
    @pos_setting = PosSetting.last
    @ledger_book = LedgerBook.new(ledger_book_params)
    if ledger_book_params[:status].present?
      @ledger_book_debit = LedgerBook.new(ledger_book_params)
      @ledger_book_debit.sys_user_id = @ledger_book_debit.status
      @ledger_book_debit.credit = nil
      @ledger_book_debit.debit = @ledger_book.credit
      @ledger_book_debit.comment = @ledger_book_debit.sys_user.name+" Transfer "+@ledger_book.credit.to_s+" To "+@ledger_book.sys_user.name+" | "+@ledger_book.comment
      @ledger_book.comment = @ledger_book.sys_user.name+" Received "+@ledger_book.credit.to_s+" From "+@ledger_book_debit.sys_user.name+" | "+@ledger_book.comment
      balance_debit=LedgerBook.where(sys_user_id: ledger_book_params[:status]).present? ? LedgerBook.where(sys_user_id: ledger_book_params[:status]).last.balance : (SysUser.find(ledger_book_params[:status]).present? ? SysUser.find(ledger_book_params[:status]).opening_balance : 0)
      balance_debit=(balance_debit.to_i-ledger_book_params[:credit].to_i)+ledger_book_params[:debit].to_i


      @ledger_book_debit.balance=balance_debit
      @ledger_book_debit.status = ''
      if @ledger_book_debit.save!
        @ledger_book_debit.payments.create(account_id: @ledger_book_debit.account_id,debit: @ledger_book.credit, credit: nil,comment: "Supplier/Both Payment | ")

      end
    else
      @ledger_book.comment = ledger_book_params[:comment]+" || "+(ledger_book_params["created_at(3i)"])+"/"+(ledger_book_params["created_at(2i)"])+"/"+(ledger_book_params["created_at(1i)"])
    end





    balance=LedgerBook.where(sys_user_id: ledger_book_params[:sys_user_id]).present? ? LedgerBook.where(sys_user_id: ledger_book_params[:sys_user_id]).last.balance : (SysUser.find(ledger_book_params[:sys_user_id]).present? ? SysUser.find(ledger_book_params[:sys_user_id]).opening_balance : 0)
    balance=(balance.to_i+ledger_book_params[:credit].to_i)-ledger_book_params[:debit].to_i

    @ledger_book.status = ''
    @ledger_book.balance=balance
    respond_to do |format|
      if @ledger_book.save
        @ledger_book.modify_account_balance
        @ledger_book.update(updated_at: @ledger_book.created_at)
        @phone = @ledger_book&.sys_user&.contact&.phone_with_comma
        if @pos_setting.sms_templates.present? && @phone.present?
          send_sms(@ledger_book.sys_user&.contact&.phone_with_comma,@pos_setting.sms_templates["user_new_ledger_credit"],'','') if @pos_setting.sms_templates["user_new_ledger_credit"].present? && @ledger_book.credit.to_f > 0
          send_sms(@ledger_book.sys_user&.contact&.phone_with_comma,@pos_setting.sms_templates["user_new_ledger_debit"],'','') if @pos_setting.sms_templates["user_new_ledger_debit"].present? && @ledger_book.debit.to_f > 0
        end
        if pos_setting_sys_type=="MobileShop"
          @suppliers=SysUser.all
          @customers=SysUser.where.not(:user_group=>['Supplier','Both'])
          format.html { redirect_to ledger_books_path, notice: 'Ledger book was successfully created.' }
        else
          format.html { redirect_to get_request_referrer, notice: 'Ledger book was successfully created.' }
        end
        format.json { render :show, status: :created, location: @ledger_book }
        if params[:commit]=="Save with Print"
          request.format = 'pdf'
          format.pdf do
            render pdf: "Sale-Order",
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
      else
        format.html { render :new }
        format.json { render json: @ledger_book.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /ledger_books/1
  # PATCH/PUT /ledger_books/1.json
  def update
    respond_to do |format|
      if @ledger_book.update(ledger_book_params)
        UserLedgerBookJob.perform_later(current_user.superAdmin.company_type,@ledger_book.sys_user_id)
        AccountPaymentJob.perform_later(current_user.superAdmin.company_type,@ledger_book.account_id)
        @ledger_book.update_account_balance
        format.html { redirect_to get_request_referrer, notice: 'Ledger book was successfully updated.' }
        format.json { render :show, status: :ok, location: @ledger_book }
      else
        format.html { render :edit }
        format.json { render json: @ledger_book.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /ledger_books/1
  # DELETE /ledger_books/1.json
  def destroy
    @sys_user = @ledger_book.sys_user
    @account = @ledger_book.account
    @ledger_book.destroy
    UserLedgerBookJob.perform_later(current_user.superAdmin.company_type,@sys_user&.id)
    AccountPaymentJob.perform_later(current_user.superAdmin.company_type,@account&.id)
    respond_to do |format|
      format.html { redirect_to get_request_referrer, notice: 'Ledger book was successfully destroyed.' }
      format.json { head :no_content }
      format.js   { render :layout => false }
    end
  end

  def transfer
    @ledger_book = LedgerBook.new
    @sys_users = SysUser.all
    @accounts = Account.all
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_ledger_book
      @ledger_book = LedgerBook.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def ledger_book_params
      params.require(:ledger_book).permit(:sys_user_id, :debit, :credit, :balance, :comment,:created_at, :account_id,:status)
    end
		def createCSV
			if params[:submit_form_csv].present?
				csv_data = asc_csv
			else
				csv_data = single_user_ledger
			end
			request.format = 'csv'
			respond_to do |format|
			format.html
			format.csv { send_data csv_data, filename: "Users - #{Date.today}.csv" }
			end
		end
end
