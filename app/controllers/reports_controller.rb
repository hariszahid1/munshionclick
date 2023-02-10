class ReportsController < ApplicationController
  include CsvMethods
  def index
    @stf_active = activated_list("Staff").count
    @stf_terminated = terminated_list("Staff").count
    @stf_deleted = deleted_list("Staff").count
    @suppliers_active=SysUser.where(:user_group=>'Supplier',status: "Active").count
    @suppliers_terminated=SysUser.where(:user_group=>'Supplier',status: "Passive").count
    @suppliers_deleted=SysUser.where(:user_group=>'Supplier',status: "Deleted").count

    @customers_active=SysUser.where(:user_group=>'Customer',status: "Active").count
    @customers_terminated=SysUser.where(:user_group=>'Customer',status: "Passive").count
    @customers_deleted=SysUser.where(:user_group=>'Customer',status: "Deleted").count

    @Both_active=SysUser.where(:user_group=>'Both',status: "Active").count
    @Both_terminated=SysUser.where(:user_group=>'Both',status: "Passive").count
    @Both_deleted=SysUser.where(:user_group=>'Both',status: "Deleted").count
    if params[:q].present?
      @expense_type = params[:q][:expense_type_eq]
    end
  end

  def chart_of_account

    @pos_setting = PosSetting.first
    @q = SysUser.where('balance > 0').order('user_group asc', 'name asc').ransack(params[:q])
    @sys_user_payable = @q.result

    @p = SysUser.where('balance < 0').order('user_group asc', 'name asc').ransack(params[:p])
    @sys_user_receiveable = @p.result

    @all_user = SysUser.all
    @user_types = UserType.all
    @staff_names = Staff.all
    @sys_user_payable_group = SysUser.where('balance > 0').group(:user_group).sum(:balance)
    @sys_user_receiveable_group = SysUser.where('balance < 0').group(:user_group).sum(:balance)
    @departments = Department.all
    @s = Staff.where('balance>0').where(deleted: false).order('department_id asc', 'name asc').ransack(params[:s])

    if params[:s].present?
      @name = params[:s][:id_eq]
      @department=params[:s][:department_id_eq]
    end

    @staff_payable = @s.result
    @staff_payable_group=Staff.joins(:department).where('balance>0').where(deleted: false).group('departments.title').sum(:balance)
    @credit_salary_list= SalaryDetail.joins(:staff).where('amount>0').where(purchase_sale_detail_id:nil,daily_book_id:nil).where.not(id: Payment.where(paymentable_type:"SalaryDetail").pluck(:paymentable_id)).group('staffs.name').sum(:amount)
    @credit_salary =     SalaryDetail.joins(:staff).where('amount>0').where(purchase_sale_detail_id:nil,daily_book_id:nil).where.not(id: Payment.where(paymentable_type:"SalaryDetail").pluck(:paymentable_id)).sum(:amount).to_f
    @k = Staff.where('balance<0').where(deleted: false).ransack(params[:k])
    if @k.result.count > 0
      @k.sorts = ['department_id asc','name asc'] if @k.sorts.empty?
    end
    if params[:k].present?
      @name = params[:k][:id_eq]
      @department=params[:k][:department_id_eq]
    end
    @staff_reciveable = @k.result
    @staff_reciveable_group=Staff.joins(:department).where('balance<0').where(deleted: false).group('departments.title').sum(:balance)

    @expense_total = ExpenseEntry.joins(:expense_type).sum(:amount)
    @expense_list = ExpenseEntry.joins(:expense_type).group('expense_types.title').having('sum(amount)>0').sum(:amount)

    @purchase_sale_detail_discount_list = PurchaseSaleDetail.where(transaction_type:'Sale').where.not(discount_price:[nil,0])
    @purchase_item_list = PurchaseSaleItem.joins(:item).where(transaction_type:'Purchase').group('items.title').having('sum(total_cost_price)>0').sum(:total_cost_price)
    @purchase_item_total = PurchaseSaleItem.joins(:item).where(transaction_type:'Purchase').sum(:total_cost_price)
    @purchase_product_list = PurchaseSaleItem.joins(:product).where(transaction_type:'Purchase').group('products.title').having('sum(total_cost_price)>0').sum(:total_cost_price)
    @purchase_product_total = PurchaseSaleItem.joins(:product).where(transaction_type:'Purchase').sum(:total_cost_price)

    @sale_item_list = PurchaseSaleItem.joins(:item).where(transaction_type:'Sale').group('items.title').having('sum(total_sale_price)>0').sum(:total_sale_price)
    @sale_item_total = PurchaseSaleItem.joins(:item).where(transaction_type:'Sale').sum(:total_sale_price)
    @sale_product_list = PurchaseSaleItem.joins(:product).where(transaction_type:'Sale').group('products.title').having('sum(total_sale_price)>0').sum(:total_sale_price)
    @sale_product_total = PurchaseSaleItem.joins(:product).where(transaction_type:'Sale').sum(:total_sale_price)
    @pos_type_batha=pos_type_batha
    if @pos_type_batha.present?
      @salary_detail_list = SalaryDetail.joins(staff: :department).where(comment:["Payment Credit",nil]).where.not('departments.id>=4').group('departments.title').sum(:amount)
      @salary_detail_kharkar    = SalaryDetail.joins(staff: :department).where(comment:["Payment Credit",nil]).where('khakar_credit>0').where.not('departments.id=4').sum(:khakar_credit)
      @salary_detail_total = SalaryDetail.joins(staff: :department).where(comment:["Payment Credit",nil]).where.not('departments.id>=4').sum(:amount)+SalaryDetail.joins(staff: :department).where(comment:["Payment Credit",nil]).where('khakar_credit>0').where.not('departments.id=4').sum(:khakar_credit)
      @khakar_salary_detail_list = SalaryDetail.joins(staff: :department).where(comment:["Payment Credit",nil]).where('khakar_credit>0').where.not('departments.id=4').group('departments.title').sum(:khakar_credit)
    else
      @salary_detail_list = SalaryDetail.joins(staff: :department).where(comment:["Payment Credit",nil]).where.not('departments.id=4').group('departments.title').sum(:amount)
      @salary_detail_kharkar    = SalaryDetail.joins(staff: :department).where(comment:["Payment Credit",nil]).where('khakar_credit>0').where.not('departments.id=4').sum(:khakar_credit)
      @salary_detail_total = SalaryDetail.joins(staff: :department).where(comment:["Payment Credit",nil]).where.not('departments.id=4').sum(:amount)+SalaryDetail.joins(staff: :department).where(comment:["Payment Credit",nil]).where('khakar_credit>0').where.not('departments.id=4').sum(:khakar_credit)
      @khakar_salary_detail_list = SalaryDetail.joins(staff: :department).where(comment:["Payment Credit",nil]).where('khakar_credit>0').where.not('departments.id=4').group('departments.title').sum(:khakar_credit)
    end
    @investments_debit = Investment.sum(:debit)
    @investments_credit = Investment.sum(:credit)
    @accounts = Account.all
    @root=root_url
    if params[:email].present?
      @pdf_index=render_to_string(:pdf => "chart of account",:template => 'reports/chart_of_account.pdf.erb',:filename => 'chart of account')
    end
    if params[:submit_pdf_staff_with].present?
      request.format = 'pdf'
      @time = Time.zone.now
      time = @time.strftime("%d")+' '+@time.strftime("%b")+' '+@time.strftime("%y")+' '+@time.strftime("at %I:%M %p")
      name = 'Chart Of Account # '+time.to_s
      print_pdf(name,'pdf.html','A4')
    end
    if params[:email].present?
      @pos_setting=PosSetting.first
      subject = "#{@pos_setting.display_name} - chart of account"
      email = current_user.superAdmin.email_to.present? ? current_user.superAdmin.email_to : "info@munshionclick.com"
      pdf=[[@pdf_index,'chart_of_account']]
      ReportMailer.new_report_email(pdf,subject,email,"").deliver
      return redirect_to reports_chart_of_account_path
    end
    if params[:submit_csv].present?
      csv_data = chart_of_account_csv
      request.format = 'csv'
      respond_to do |format|
        format.html
        format.csv { send_data csv_data, filename: "Chart of Account - #{Date.today}.csv" }
      end
    end
    
    chart_of_account_analytics
    
  end

  def trial_balance

    @pos_setting=PosSetting.first
    @q = SysUser.where('balance > 0').ransack(params[:q])
    if @q.result.count > 0
      @q.sorts = ['user_group asc','name asc'] if @q.sorts.empty?
    end
    @sys_user_payable = @q.result
    @sys_user_payable_ledger_book_debit = LedgerBook.group('sys_user_id').sum(:debit)
    @sys_user_payable_ledger_book_credit = LedgerBook.group('sys_user_id').sum(:credit)
    @sys_user_payable_ledger_book_debit_total = LedgerBook.where('debit > 0').where(sys_user_id: @sys_user_payable.ids).sum(:debit)
    @sys_user_payable_ledger_book_credit_total = LedgerBook.where('credit > 0').where(sys_user_id: @sys_user_payable.ids).sum(:credit)



    @p =SysUser.where('balance < 0').ransack(params[:p])
    if @p.result.count > 0
      @p.sorts = ['user_group asc','name asc'] if @p.sorts.empty?
    end

    @sys_user_receiveable = @p.result
    @sys_user_receiveable_ledger_book_debit = LedgerBook.group('sys_user_id').sum(:debit)
    @sys_user_receiveable_ledger_book_credit = LedgerBook.group('sys_user_id').sum(:credit)
    @sys_user_receiveable_ledger_book_debit_total = LedgerBook.where('debit > 0').where(sys_user_id: @sys_user_receiveable.ids).sum(:debit)
    @sys_user_receiveable_ledger_book_credit_total = LedgerBook.where('credit > 0').where(sys_user_id: @sys_user_receiveable.ids).sum(:credit)


    @n = SysUser.where(balance: 0).ransack(params[:n])
    if @n.result.count > 0
      @n.sorts = ['user_group asc','name asc'] if @p.sorts.empty?
    end
    @sys_user_nill = @n.result
    @sys_user_nill_ledger_book_debit = LedgerBook.group('sys_user_id').sum(:debit)
    @sys_user_nill_ledger_book_credit = LedgerBook.group('sys_user_id').sum(:credit)
    @sys_user_nill_ledger_book_debit_total = LedgerBook.where('debit > 0').where(sys_user_id: @sys_user_nill.ids).sum(:debit)
    @sys_user_nill_ledger_book_credit_total = LedgerBook.where('credit > 0').where(sys_user_id: @sys_user_nill.ids).sum(:credit)


    @all_user =SysUser.all
    @user_types=UserType.all
    @staff_names=Staff.all
    @sys_user_payable_group=SysUser.where('balance > 0').group(:user_group).sum(:balance)
    @sys_user_receiveable_group=SysUser.where('balance < 0').group(:user_group).sum(:balance)
    @departments=Department.all
    @s = Staff.where('balance>0').where(deleted: false).ransack(params[:s])
    if @s.result.count > 0
      @s.sorts = ['department_id asc','name asc'] if @s.sorts.empty?
    end
    if params[:s].present?
      @name = params[:s][:id_eq]
      @department=params[:s][:department_id_eq]
    end

    @staff_payable = @s.result
    @staff_payable_group=Staff.joins(:department).where('balance>0').where(deleted: false).group('departments.title').sum(:balance)
    @credit_salary_list= SalaryDetail.joins(:staff).where('amount>0').where(purchase_sale_detail_id:nil,daily_book_id:nil).where.not(id: Payment.where(paymentable_type:"SalaryDetail").pluck(:paymentable_id)).group('staffs.name').sum(:amount)
    @credit_salary =     SalaryDetail.joins(:staff).where('amount>0').where(purchase_sale_detail_id:nil,daily_book_id:nil).where.not(id: Payment.where(paymentable_type:"SalaryDetail").pluck(:paymentable_id)).sum(:amount).to_f
    @staff_payable_ledger_book_debit = StaffLedgerBook.group('staff_id').sum(:debit)
    @staff_payable_ledger_book_credit = StaffLedgerBook.group('staff_id').sum(:credit)
    @staff_payable_ledger_book_debit_total = StaffLedgerBook.where('debit > 0').where(staff_id: @staff_payable.ids).sum(:debit)
    @staff_payable_ledger_book_credit_total = StaffLedgerBook.where('credit > 0').where(staff_id: @staff_payable.ids).sum(:credit)

    @k = Staff.where('balance<0').where(deleted: false).ransack(params[:k])
    if @k.result.count > 0
      @k.sorts = ['department_id asc','name asc'] if @k.sorts.empty?
    end
    if params[:k].present?
      @name = params[:k][:id_eq]
      @department=params[:k][:department_id_eq]
    end
    @staff_reciveable = @k.result
    @staff_reciveable_group=Staff.joins(:department).where('balance<0').where(deleted: false).group('departments.title').sum(:balance)
    @staff_reciveable_ledger_book_debit = StaffLedgerBook.group('staff_id').sum(:debit)
    @staff_reciveable_ledger_book_credit = StaffLedgerBook.group('staff_id').sum(:credit)
    @staff_reciveable_ledger_book_debit_total = StaffLedgerBook.where('debit > 0').where(staff_id: @staff_reciveable.ids).sum(:debit)
    @staff_reciveable_ledger_book_credit_total = StaffLedgerBook.where('credit > 0').where(staff_id: @staff_reciveable.ids).sum(:credit)


    @sn = Staff.where(balance:0).where(deleted: false).ransack(params[:k])
    if @sn.result.count > 0
      @sn.sorts = ['department_id asc','name asc'] if @k.sorts.empty?
    end
    if params[:sn].present?
      @name = params[:sn][:id_eq]
      @department=params[:sn][:department_id_eq]
    end
    @staff_nill = @sn.result
    @staff_nill_group=Staff.joins(:department).where(balance:0).where(deleted: false).group('departments.title').sum(:balance)
    @staff_nill_ledger_book_debit = StaffLedgerBook.group('staff_id').sum(:debit)
    @staff_nill_ledger_book_credit = StaffLedgerBook.group('staff_id').sum(:credit)
    @staff_nill_ledger_book_debit_total = StaffLedgerBook.where('debit > 0').where(staff_id: @staff_nill.ids).sum(:debit)
    @staff_nill_ledger_book_credit_total = StaffLedgerBook.where('credit > 0').where(staff_id: @staff_nill.ids).sum(:credit)


    @accounts = Account.all
    @account_debit = Payment.joins(:account).group(:title).sum(:debit)
    @account_credit = Payment.joins(:account).group(:title).sum(:credit)
    @account_debit_total = Payment.joins(:account).sum(:debit)
    @account_credit_total = Payment.joins(:account).sum(:credit)


    @expense_total = ExpenseEntry.joins(:expense_type).sum(:amount)
    @expense_list = ExpenseEntry.joins(:expense_type).group('expense_types.id','expense_types.title').sum(:amount)

    @credit_expense = ExpenseEntry.joins(:payment).joins(:expense_type).group('expense_types.title').sum(:debit)
    @total_credit_expense = ExpenseEntry.joins(:payment).sum(:debit)

    @purchase_sale_detail_discount_list = PurchaseSaleDetail.where(transaction_type:'Sale').where.not(discount_price:[nil,0])
    @purchase_item_list = PurchaseSaleItem.joins(:item).where(transaction_type:'Purchase').group('items.title').having('sum(total_cost_price)>0').sum(:total_cost_price)
    @purchase_item_total = PurchaseSaleItem.joins(:item).where(transaction_type:'Purchase').sum(:total_cost_price)
    @purchase_product_list = PurchaseSaleItem.joins(:product).where(transaction_type:'Purchase').group('products.title').having('sum(total_cost_price)>0').sum(:total_cost_price)
    @purchase_product_total = PurchaseSaleItem.joins(:product).where(transaction_type:'Purchase').sum(:total_cost_price)

    @sale_item_list = PurchaseSaleItem.joins(:item).where(transaction_type:'Sale').group('items.title').having('sum(total_sale_price)>0').sum(:total_sale_price)
    @sale_item_total = PurchaseSaleItem.joins(:item).where(transaction_type:'Sale').sum(:total_sale_price)
    @sale_product_list = PurchaseSaleItem.joins(:product).where(transaction_type:'Sale').group('products.title').having('sum(total_sale_price)>0').sum(:total_sale_price)
    @sale_product_total = PurchaseSaleItem.joins(:product).where(transaction_type:'Sale').sum(:total_sale_price)
    @pos_type_batha=pos_type_batha
    if @pos_type_batha.present?
      @salary_detail_list = SalaryDetail.joins(staff: :department).where(comment:["Payment Credit",nil]).where.not('departments.id>=4').group('departments.title').sum(:amount)
      @salary_detail_kharkar    = SalaryDetail.joins(staff: :department).where(comment:["Payment Credit",nil]).where('khakar_credit>0').where.not('departments.id=4').sum(:khakar_credit)
      @salary_detail_total = SalaryDetail.joins(staff: :department).where(comment:["Payment Credit",nil]).where.not('departments.id>=4').sum(:amount)+SalaryDetail.joins(staff: :department).where(comment:["Payment Credit",nil]).where('khakar_credit>0').where.not('departments.id=4').sum(:khakar_credit)
      @khakar_salary_detail_list = SalaryDetail.joins(staff: :department).where(comment:["Payment Credit",nil]).where('khakar_credit>0').where.not('departments.id=4').group('departments.title').sum(:khakar_credit)
    else
      @salary_detail_list = SalaryDetail.joins(staff: :department).where(comment:["Payment Credit",nil]).where.not('departments.id=4').group('departments.title').sum(:amount)
      @salary_detail_kharkar    = SalaryDetail.joins(staff: :department).where(comment:["Payment Credit",nil]).where('khakar_credit>0').where.not('departments.id=4').sum(:khakar_credit)
      @salary_detail_total = SalaryDetail.joins(staff: :department).where(comment:["Payment Credit",nil]).where.not('departments.id=4').sum(:amount)+SalaryDetail.joins(staff: :department).where(comment:["Payment Credit",nil]).where('khakar_credit>0').where.not('departments.id=4').sum(:khakar_credit)
      @khakar_salary_detail_list = SalaryDetail.joins(staff: :department).where(comment:["Payment Credit",nil]).where('khakar_credit>0').where.not('departments.id=4').group('departments.title').sum(:khakar_credit)
    end
    @investments_debit = Investment.sum(:debit)
    @investments_credit = Investment.sum(:credit)
    @accounts = Account.all
    @root=root_url

    return user_group_pdf if params[:user_group_pdf].present? || params[:without_zero_pdf].present?
    return user_group_all_pdf if params[:user_group_all_pdf].present?

    if params[:email].present?
      @pdf_index=render_to_string(:pdf => "trial balance",:template => 'reports/trial_balance.pdf.erb',:filename => 'trail balance')
    end
    if params[:submit_pdf_staff_with].present?
      request.format = 'pdf'
      @time = Time.zone.now
      time = @time.strftime("%d")+' '+@time.strftime("%b")+' '+@time.strftime("%y")+' '+@time.strftime("at %I:%M %p")
      name = 'Trail Balance # '+time.to_s
      print_pdf(name,'pdf.html','A4')
    end
    if params[:email].present?
      @pos_setting=PosSetting.first
      subject = "#{@pos_setting.display_name} - trail balance"
      email = current_user.superAdmin.email_to.present? ? current_user.superAdmin.email_to : "info@munshionclick.com"
      pdf=[[@pdf_index,'trail_balance']]
      ReportMailer.new_report_email(pdf,subject,email,"").deliver
      return redirect_to reports_chart_of_account_path
    end
    if params[:submit_csv].present?
      csv_data = trail_balance_csv
      request.format = 'csv'
      respond_to do |format|
        format.html
        format.csv { send_data csv_data, filename: "Trail Balance - #{Date.today}.csv" }
      end
    end
  end

  def six_trial_balance

    from_date = params[:q][:created_at_lteq].to_date.beginning_of_day
    to_date = params[:q][:created_at_gteq].to_date.end_of_day

    #sys_users_data
    @sys_users = SysUser.all.order(['user_group asc', 'name asc'])

    sys_user_ids = @sys_users.ids

    @ledger_books_current = LedgerBook.where(sys_user_id: sys_user_ids)
                                      .where('created_at BETWEEN ? AND ?', from_date, to_date)

    @ledger_books_opening = LedgerBook.where(sys_user_id: sys_user_ids)
                                      .where('created_at < ?', from_date)

    @ledger_books_closing = LedgerBook.where(sys_user_id: sys_user_ids)
                                      .where('created_at > ?', to_date)

    @sys_user_ledger_book_debit_current = @ledger_books_current.group('sys_user_id').sum(:debit)
    @sys_user_ledger_book_credit_current = @ledger_books_current.group('sys_user_id').sum(:credit)
    @sys_user_ledger_book_debit_current_total = @ledger_books_current.sum(:debit)
    @sys_user_ledger_book_credit_current_total = @ledger_books_current.sum(:credit)

    @sys_user_ledger_book_debit_opening = @ledger_books_opening.group('sys_user_id').sum(:debit)
    @sys_user_ledger_book_credit_opening = @ledger_books_opening.group('sys_user_id').sum(:credit)
    @sys_user_ledger_book_debit_opening_total = @ledger_books_opening.sum(:debit)
    @sys_user_ledger_book_credit_opening_total = @ledger_books_opening.sum(:credit)

    @sys_user_ledger_book_debit_closing = @ledger_books_closing.group('sys_user_id').sum(:debit)
    @sys_user_ledger_book_credit_closing = @ledger_books_closing.group('sys_user_id').sum(:credit)
    @sys_user_ledger_book_debit_closing_total = @ledger_books_closing.sum(:debit)
    @sys_user_ledger_book_credit_closing_total = @ledger_books_closing.sum(:credit)

    # staffs_data
    @staffs = Staff.all.order(['department_id asc', 'name asc'])
    staff_ids = @staffs.ids

    @ledger_books_current = StaffLedgerBook.where(staff_id: staff_ids)
                                           .where('created_at BETWEEN ? AND ?', from_date, to_date)

    @ledger_books_opening = StaffLedgerBook.where(staff_id: staff_ids)
                                           .where('created_at < ?', from_date)

    @ledger_books_closing = StaffLedgerBook.where(staff_id: staff_ids)
                                           .where('created_at > ?', to_date)

    @staff_ledger_book_debit_current = @ledger_books_current.group('staff_id').sum(:debit)
    @staff_ledger_book_credit_current = @ledger_books_current.group('staff_id').sum(:credit)
    @staff_ledger_book_debit_current_total = @ledger_books_current.sum(:debit)
    @staff_ledger_book_credit_current_total = @ledger_books_current.sum(:credit)

    @staff_ledger_book_debit_opening = @ledger_books_opening.group('staff_id').sum(:debit)
    @staff_ledger_book_credit_opening = @ledger_books_opening.group('staff_id').sum(:credit)
    @staff_ledger_book_debit_opening_total = @ledger_books_opening.sum(:debit)
    @staff_ledger_book_credit_opening_total = @ledger_books_opening.sum(:credit)

    @staff_ledger_book_debit_closing = @ledger_books_closing.group('staff_id').sum(:debit)
    @staff_ledger_book_credit_closing = @ledger_books_closing.group('staff_id').sum(:credit)
    @staff_ledger_book_debit_closing_total = @ledger_books_closing.sum(:debit)
    @staff_ledger_book_credit_closing_total = @ledger_books_closing.sum(:credit)

    #accounts_data

    @accounts = Account.all
    account_ids = @accounts.ids

    @account_current = Payment.where(account_id: account_ids)
                              .where('created_at BETWEEN ? AND ?', from_date, to_date)

    @account_opening = Payment.where(account_id: account_ids)
                              .where('created_at < ?', from_date)

    @account_closing = Payment.where(account_id: account_ids)
                              .where('created_at > ?', to_date)

    @account_debit_current = @account_current.group('account_id').sum(:debit)
    @account_credit_current = @account_current.group('account_id').sum(:credit)
    @account_debit_current_total = @account_current.sum(:debit)
    @account_credit_current_total = @account_current.sum(:credit)

    @account_debit_opening = @account_opening.group('account_id').sum(:debit)
    @account_credit_opening = @account_opening.group('account_id').sum(:credit)
    @account_debit_opening_total = @account_opening.sum(:debit)
    @account_credit_opening_total = @account_opening.sum(:credit)

    @account_debit_closing = @account_closing.group('account_id').sum(:debit)
    @account_credit_closing = @account_closing.group('account_id').sum(:credit)
    @account_debit_closing_total = @account_closing.sum(:debit)
    @account_credit_closing_total = @account_closing.sum(:credit)

    request.format = 'pdf'
    @time = Time.zone.now
    time = @time.strftime("%d")+' '+@time.strftime("%b")+' '+@time.strftime("%y")+' '+@time.strftime("at %I:%M %p")
    name = '6 Trail Balance # '+time.to_s
    print_pdf(name,'pdf.html','A4')
  end

  def user_group_pdf
    @sys_user_payable_customer, @sys_user_payable_customer_ledger_book_debit, @sys_user_payable_customer_ledger_book_credit, @sys_user_payable_customer_ledger_book_debit_total, @sys_user_payable_customer_ledger_book_credit_total = get_payable_data(0)
    @sys_user_payable_own, @sys_user_payable_own_ledger_book_debit, @sys_user_payable_own_ledger_book_credit, @sys_user_payable_own_ledger_book_debit_total, @sys_user_payable_own_ledger_book_credit_total = get_payable_data(4)
    @sys_user_payable_supplier, @sys_user_payable_supplier_ledger_book_debit, @sys_user_payable_supplier_ledger_book_credit, @sys_user_payable_supplier_ledger_book_debit_total, @sys_user_payable_supplier_ledger_book_credit_total = get_payable_data(1)
    @sys_user_payable_salesman, @sys_user_payable_salesman_ledger_book_debit, @sys_user_payable_salesman_ledger_book_credit, @sys_user_payable_salesman_ledger_book_debit_total, @sys_user_payable_salesman_ledger_book_credit_total = get_payable_data(3)
    @sys_user_payable_both, @sys_user_payable_both_ledger_book_debit, @sys_user_payable_both_ledger_book_credit, @sys_user_payable_both_ledger_book_debit_total, @sys_user_payable_both_ledger_book_credit_total = get_payable_data(2)
    @sys_user_payable_investor, @sys_user_payable_investor_ledger_book_debit, @sys_user_payable_investor_ledger_book_credit, @sys_user_payable_investor_ledger_book_debit_total, @sys_user_payable_investor_ledger_book_credit_total = get_payable_data(5)
    @sys_user_payable_investment, @sys_user_payable_investment_ledger_book_debit, @sys_user_payable_investment_ledger_book_credit, @sys_user_payable_investment_ledger_book_debit_total, @sys_user_payable_investment_ledger_book_credit_total = get_payable_data(6)
    @sys_user_payable_worker, @sys_user_payable_worker_ledger_book_debit, @sys_user_payable_worker_ledger_book_credit, @sys_user_payable_worker_ledger_book_debit_total, @sys_user_payable_worker_ledger_book_credit_total = get_payable_data(7)
    @sys_user_payable_other, @sys_user_payable_other_ledger_book_debit, @sys_user_payable_other_ledger_book_credit, @sys_user_payable_other_ledger_book_debit_total, @sys_user_payable_other_ledger_book_credit_total = get_payable_data(8)
    @sys_user_payable_landlord, @sys_user_payable_landlord_ledger_book_debit, @sys_user_payable_landlord_ledger_book_credit, @sys_user_payable_landlord_ledger_book_debit_total, @sys_user_payable_landlord_ledger_book_credit_total = get_payable_data(9)
    @sys_user_payable_md_investment, @sys_user_payable_md_investment_ledger_book_debit, @sys_user_payable_md_investment_ledger_book_credit, @sys_user_payable_md_investment_ledger_book_debit_total, @sys_user_payable_md_investment_ledger_book_credit_total = get_payable_data(10)

    @sys_user_recievable_customer, @sys_user_recievable_customer_ledger_book_debit, @sys_user_recievable_customer_ledger_book_credit, @sys_user_recievable_customer_ledger_book_debit_total, @sys_user_recievable_customer_ledger_book_credit_total = get_recievable_data(0)
    @sys_user_recievable_own, @sys_user_recievable_own_ledger_book_debit, @sys_user_recievable_own_ledger_book_credit, @sys_user_recievable_own_ledger_book_debit_total, @sys_user_recievable_own_ledger_book_credit_total = get_recievable_data(4)
    @sys_user_recievable_supplier, @sys_user_recievable_supplier_ledger_book_debit, @sys_user_recievable_supplier_ledger_book_credit, @sys_user_recievable_supplier_ledger_book_debit_total, @sys_user_recievable_supplier_ledger_book_credit_total = get_recievable_data(1)
    @sys_user_recievable_salesman, @sys_user_recievable_salesman_ledger_book_debit, @sys_user_recievable_salesman_ledger_book_credit, @sys_user_recievable_salesman_ledger_book_debit_total, @sys_user_recievable_salesman_ledger_book_credit_total = get_recievable_data(3)
    @sys_user_recievable_both, @sys_user_recievable_both_ledger_book_debit, @sys_user_recievable_both_ledger_book_credit, @sys_user_recievable_both_ledger_book_debit_total, @sys_user_recievable_both_ledger_book_credit_total = get_recievable_data(2)
    @sys_user_recievable_investor, @sys_user_recievable_investor_ledger_book_debit, @sys_user_recievable_investor_ledger_book_credit, @sys_user_recievable_investor_ledger_book_debit_total, @sys_user_recievable_investor_ledger_book_credit_total = get_recievable_data(5)
    @sys_user_recievable_investment, @sys_user_recievable_investment_ledger_book_debit, @sys_user_recievable_investment_ledger_book_credit, @sys_user_recievable_investment_ledger_book_debit_total, @sys_user_recievable_investment_ledger_book_credit_total = get_recievable_data(6)
    @sys_user_recievable_worker, @sys_user_recievable_worker_ledger_book_debit, @sys_user_recievable_worker_ledger_book_credit, @sys_user_recievable_worker_ledger_book_debit_total, @sys_user_recievable_worker_ledger_book_credit_total = get_recievable_data(7)
    @sys_user_recievable_other, @sys_user_recievable_other_ledger_book_debit, @sys_user_recievable_other_ledger_book_credit, @sys_user_recievable_other_ledger_book_debit_total, @sys_user_recievable_other_ledger_book_credit_total = get_recievable_data(8)
    @sys_user_recievable_landlord, @sys_user_recievable_landlord_ledger_book_debit, @sys_user_recievable_landlord_ledger_book_credit, @sys_user_recievable_landlord_ledger_book_debit_total, @sys_user_recievable_landlord_ledger_book_credit_total = get_recievable_data(9)
    @sys_user_recievable_md_investment, @sys_user_recievable_md_investment_ledger_book_debit, @sys_user_recievable_md_investment_ledger_book_credit, @sys_user_recievable_md_investment_ledger_book_debit_total, @sys_user_recievable_md_investment_ledger_book_credit_total = get_recievable_data(10)

    @sys_user_nil_customer, @sys_user_nil_customer_ledger_book_debit, @sys_user_nil_customer_ledger_book_credit, @sys_user_nil_customer_ledger_book_debit_total, @sys_user_nil_customer_ledger_book_credit_total = get_nil_data(0)
    @sys_user_nil_own, @sys_user_nil_own_ledger_book_debit, @sys_user_nil_own_ledger_book_credit, @sys_user_nil_own_ledger_book_debit_total, @sys_user_nil_own_ledger_book_credit_total = get_nil_data(4)
    @sys_user_nil_supplier, @sys_user_nil_supplier_ledger_book_debit, @sys_user_nil_supplier_ledger_book_credit, @sys_user_nil_supplier_ledger_book_debit_total, @sys_user_nil_supplier_ledger_book_credit_total = get_nil_data(1)
    @sys_user_nil_salesman, @sys_user_nil_salesman_ledger_book_debit, @sys_user_nil_salesman_ledger_book_credit, @sys_user_nil_salesman_ledger_book_debit_total, @sys_user_nil_salesman_ledger_book_credit_total = get_nil_data(3)
    @sys_user_nil_both, @sys_user_nil_both_ledger_book_debit, @sys_user_nil_both_ledger_book_credit, @sys_user_nil_both_ledger_book_debit_total, @sys_user_nil_both_ledger_book_credit_total = get_nil_data(2)
    @sys_user_nil_investor, @sys_user_nil_investor_ledger_book_debit, @sys_user_nil_investor_ledger_book_credit, @sys_user_nil_investor_ledger_book_debit_total, @sys_user_nil_investor_ledger_book_credit_total = get_nil_data(5)
    @sys_user_nil_investment, @sys_user_nil_investment_ledger_book_debit, @sys_user_nil_investment_ledger_book_credit, @sys_user_nil_investment_ledger_book_debit_total, @sys_user_nil_investment_ledger_book_credit_total = get_nil_data(6)
    @sys_user_nil_worker, @sys_user_nil_worker_ledger_book_debit, @sys_user_nil_worker_ledger_book_credit, @sys_user_nil_worker_ledger_book_debit_total, @sys_user_nil_worker_ledger_book_credit_total = get_nil_data(7)
    @sys_user_nil_other, @sys_user_nil_other_ledger_book_debit, @sys_user_nil_other_ledger_book_credit, @sys_user_nil_other_ledger_book_debit_total, @sys_user_nil_other_ledger_book_credit_total = get_nil_data(8)
    @sys_user_nil_landlord, @sys_user_nil_landlord_ledger_book_debit, @sys_user_nil_landlord_ledger_book_credit, @sys_user_nil_landlord_ledger_book_debit_total, @sys_user_nil_landlord_ledger_book_credit_total = get_nil_data(9)
    @sys_user_nil_md_investment, @sys_user_nil_md_investment_ledger_book_debit, @sys_user_nil_md_investment_ledger_book_credit, @sys_user_nil_md_investment_ledger_book_debit_total, @sys_user_nil_md_investment_ledger_book_credit_total = get_nil_data(10)

    @departments_for_staffs = Department.joins(staffs: :staff_ledger_books).includes(staffs: :staff_ledger_books)

    request.format = 'pdf'
    @time = Time.zone.now
    time = @time.strftime("%d")+' '+@time.strftime("%b")+' '+@time.strftime("%y")+' '+@time.strftime("at %I:%M %p")
    name = 'Trail Balance # '+time.to_s
    print_pdf(name,'pdf.html','A4')
  end

  def user_group_all_pdf
    @sys_user_customer, @sys_user_customer_ledger_book_debit, @sys_user_customer_ledger_book_credit, @sys_user_customer_ledger_book_debit_total, @sys_user_customer_ledger_book_credit_total = get_all_data(0)
    @sys_user_own, @sys_user_own_ledger_book_debit, @sys_user_own_ledger_book_credit, @sys_user_own_ledger_book_debit_total, @sys_user_own_ledger_book_credit_total = get_all_data(4)
    @sys_user_supplier, @sys_user_supplier_ledger_book_debit, @sys_user_supplier_ledger_book_credit, @sys_user_supplier_ledger_book_debit_total, @sys_user_supplier_ledger_book_credit_total = get_all_data(1)
    @sys_user_salesman, @sys_user_salesman_ledger_book_debit, @sys_user_salesman_ledger_book_credit, @sys_user_salesman_ledger_book_debit_total, @sys_user_salesman_ledger_book_credit_total = get_all_data(3)
    @sys_user_both, @sys_user_both_ledger_book_debit, @sys_user_both_ledger_book_credit, @sys_user_both_ledger_book_debit_total, @sys_user_both_ledger_book_credit_total = get_all_data(2)
    @sys_user_investor, @sys_user_investor_ledger_book_debit, @sys_user_investor_ledger_book_credit, @sys_user_investor_ledger_book_debit_total, @sys_user_investor_ledger_book_credit_total = get_all_data(5)
    @sys_user_investment, @sys_user_investment_ledger_book_debit, @sys_user_investment_ledger_book_credit, @sys_user_investment_ledger_book_debit_total, @sys_user_investment_ledger_book_credit_total = get_all_data(6)
    @sys_user_worker, @sys_user_worker_ledger_book_debit, @sys_user_worker_ledger_book_credit, @sys_user_worker_ledger_book_debit_total, @sys_user_worker_ledger_book_credit_total = get_all_data(7)
    @sys_user_other, @sys_user_other_ledger_book_debit, @sys_user_other_ledger_book_credit, @sys_user_other_ledger_book_debit_total, @sys_user_other_ledger_book_credit_total = get_all_data(8)
    @sys_user_landlord, @sys_user_landlord_ledger_book_debit, @sys_user_landlord_ledger_book_credit, @sys_user_landlord_ledger_book_debit_total, @sys_user_landlord_ledger_book_credit_total = get_all_data(9)
    @sys_user_md_investment, @sys_user_md_investment_ledger_book_debit, @sys_user_md_investment_ledger_book_credit, @sys_user_md_investment_ledger_book_debit_total, @sys_user_md_investment_ledger_book_credit_total = get_all_data(10)

    @departments_for_staffs = Department.joins(staffs: :staff_ledger_books).includes(staffs: :staff_ledger_books)

    request.format = 'pdf'
    @time = Time.zone.now
    time = @time.strftime("%d")+' '+@time.strftime("%b")+' '+@time.strftime("%y")+' '+@time.strftime("at %I:%M %p")
    name = 'Trail Balance # '+time.to_s
    print_pdf(name,'pdf.html','A4')
  end

  def get_all_data(user_group)
    sys_users = SysUser.where(user_group: user_group).order('user_group asc', 'name asc')
    ledger_book_debit = LedgerBook.group('sys_user_id').sum(:debit)
    ledger_book_credit = LedgerBook.group('sys_user_id').sum(:credit)
    ledger_book_debit_total = LedgerBook.where('debit > 0').where(sys_user_id: sys_users.ids).sum(:debit)
    ledger_book_credit_total = LedgerBook.where('credit > 0').where(sys_user_id: sys_users.ids).sum(:credit)

    return sys_users, ledger_book_debit, ledger_book_credit, ledger_book_debit_total, ledger_book_credit_total
  end

  def get_recievable_data(user_group)
    sys_users = SysUser.where('balance < ? && user_group = ?', 0, user_group).order('user_group asc', 'name asc')
    ledger_book_debit = LedgerBook.group('sys_user_id').sum(:debit)
    ledger_book_credit = LedgerBook.group('sys_user_id').sum(:credit)
    ledger_book_debit_total = LedgerBook.where('debit > 0').where(sys_user_id: sys_users.ids).sum(:debit)
    ledger_book_credit_total = LedgerBook.where('credit > 0').where(sys_user_id: sys_users.ids).sum(:credit)

    return sys_users, ledger_book_debit, ledger_book_credit, ledger_book_debit_total, ledger_book_credit_total
  end

  def get_payable_data(user_group)
    sys_users = SysUser.where('balance > ? && user_group = ?', 0, user_group).order('user_group asc', 'name asc')
    ledger_book_debit = LedgerBook.group('sys_user_id').sum(:debit)
    ledger_book_credit = LedgerBook.group('sys_user_id').sum(:credit)
    ledger_book_debit_total = LedgerBook.where('debit > 0').where(sys_user_id: sys_users.ids).sum(:debit)
    ledger_book_credit_total = LedgerBook.where('credit > 0').where(sys_user_id: sys_users.ids).sum(:credit)

    return sys_users, ledger_book_debit, ledger_book_credit, ledger_book_debit_total, ledger_book_credit_total
  end

  def get_nil_data(user_group)
    sys_users = SysUser.where(balance: 0, user_group: user_group).order('user_group asc', 'name asc')
    ledger_book_debit = LedgerBook.group('sys_user_id').sum(:debit)
    ledger_book_credit = LedgerBook.group('sys_user_id').sum(:credit)
    ledger_book_debit_total = LedgerBook.where('debit > 0').where(sys_user_id: sys_users.ids).sum(:debit)
    ledger_book_credit_total = LedgerBook.where('credit > 0').where(sys_user_id: sys_users.ids).sum(:credit)

    return sys_users, ledger_book_debit, ledger_book_credit, ledger_book_debit_total, ledger_book_credit_total
  end

# trial balance partialy data start

  def trial_balance_users_payable
    @pos_setting=PosSetting.first
    @q = SysUser.where('balance > 0').order('user_group asc', 'name asc').ransack(params[:q])
    @sys_user_payable = @q.result
    @sys_user_payable_ledger_book_debit = LedgerBook.group('sys_user_id').sum(:debit)
    @sys_user_payable_ledger_book_credit = LedgerBook.group('sys_user_id').sum(:credit)
    @sys_user_payable_ledger_book_debit_total = LedgerBook.where('debit > 0').where(sys_user_id: @sys_user_payable.ids).sum(:debit)
    @sys_user_payable_ledger_book_credit_total = LedgerBook.where('credit > 0').where(sys_user_id: @sys_user_payable.ids).sum(:credit)

    respond_to do |format|
      format.js
    end
  end

  def trial_balance_users_reciveable
    @q = SysUser.where('balance < 0').order('user_group asc', 'name asc').ransack(params[:q])
    @sys_user_receiveable = @q.result
    @sys_user_receiveable_ledger_book_debit = LedgerBook.group('sys_user_id').sum(:debit)
    @sys_user_receiveable_ledger_book_credit = LedgerBook.group('sys_user_id').sum(:credit)
    @sys_user_receiveable_ledger_book_debit_total = LedgerBook.where('debit > 0').where(sys_user_id: @sys_user_receiveable.ids).sum(:debit)
    @sys_user_receiveable_ledger_book_credit_total = LedgerBook.where('credit > 0').where(sys_user_id: @sys_user_receiveable.ids).sum(:credit)
    respond_to do |format|
      format.js
    end
  end

  def trial_balance_users_nill
    @q = SysUser.where(balance: 0).order('user_group asc', 'name asc').ransack(params[:q])
    @sys_user_nill = @q.result
    @sys_user_nill_ledger_book_debit = LedgerBook.group('sys_user_id').sum(:debit)
    @sys_user_nill_ledger_book_credit = LedgerBook.group('sys_user_id').sum(:credit)
    @sys_user_nill_ledger_book_debit_total = LedgerBook.where('debit > 0').where(sys_user_id: @sys_user_nill.ids).sum(:debit)
    @sys_user_nill_ledger_book_credit_total = LedgerBook.where('credit > 0').where(sys_user_id: @sys_user_nill.ids).sum(:credit)
    respond_to do |format|
      format.js
    end
  end
  def trial_balance_staffs_payable
    @all_user = SysUser.all
    @user_types = UserType.all
    @staff_names = Staff.all
    @sys_user_payable_group = SysUser.where('balance > 0').group(:user_group).sum(:balance)
    @sys_user_receiveable_group = SysUser.where('balance < 0').group(:user_group).sum(:balance)
    @departments = Department.all
    @q = Staff.where('balance>0').where(deleted: false).order('department_id asc', 'name asc').ransack(params[:q])

    @staff_payable = @q.result
    @staff_payable_group = Staff.joins(:department).where('balance>0').where(deleted: false).group('departments.title').sum(:balance)
    @credit_salary_list = SalaryDetail.joins(:staff).where('amount>0').where(purchase_sale_detail_id:nil,daily_book_id:nil).where.not(id: Payment.where(paymentable_type:"SalaryDetail").pluck(:paymentable_id)).group('staffs.name').sum(:amount)
    @credit_salary = SalaryDetail.joins(:staff).where('amount>0').where(purchase_sale_detail_id:nil,daily_book_id:nil).where.not(id: Payment.where(paymentable_type:"SalaryDetail").pluck(:paymentable_id)).sum(:amount).to_f
    @staff_payable_ledger_book_debit = StaffLedgerBook.group('staff_id').sum(:debit)
    @staff_payable_ledger_book_credit = StaffLedgerBook.group('staff_id').sum(:credit)
    @staff_payable_ledger_book_debit_total = StaffLedgerBook.where('debit > 0').where(staff_id: @staff_payable.ids).sum(:debit)
    @staff_payable_ledger_book_credit_total = StaffLedgerBook.where('credit > 0').where(staff_id: @staff_payable.ids).sum(:credit)
    respond_to do |format|
      format.js
    end
  end
  def trial_balance_staffs_reciveable
    @all_user = SysUser.all
    @user_types = UserType.all
    @staff_names = Staff.all
    @sys_user_payable_group = SysUser.where('balance > 0').group(:user_group).sum(:balance)
    @sys_user_receiveable_group = SysUser.where('balance < 0').group(:user_group).sum(:balance)
    @departments = Department.all
    @q = Staff.where('balance<0').where(deleted: false).order('department_id asc', 'name asc').ransack(params[:q])

    @staff_reciveable = @q.result
    @staff_reciveable_group = Staff.joins(:department).where('balance<0').where(deleted: false).group('departments.title').sum(:balance)
    @staff_reciveable_ledger_book_debit = StaffLedgerBook.group('staff_id').sum(:debit)
    @staff_reciveable_ledger_book_credit = StaffLedgerBook.group('staff_id').sum(:credit)
    @staff_reciveable_ledger_book_debit_total = StaffLedgerBook.where('debit > 0').where(staff_id: @staff_reciveable.ids).sum(:debit)
    @staff_reciveable_ledger_book_credit_total = StaffLedgerBook.where('credit > 0').where(staff_id: @staff_reciveable.ids).sum(:credit)
    respond_to do |format|
      format.js
    end
  end
  def trial_balance_staffs_nill
    @all_user = SysUser.all
    @user_types = UserType.all
    @staff_names = Staff.all
    @sys_user_payable_group = SysUser.where('balance > 0').group(:user_group).sum(:balance)
    @sys_user_receiveable_group = SysUser.where('balance < 0').group(:user_group).sum(:balance)
    @departments = Department.all
    @q = Staff.where(balance:0).where(deleted: false).order('department_id asc', 'name asc').ransack(params[:q])
    @staff_nill = @q.result
    @staff_nill_group=Staff.joins(:department).where(balance:0).where(deleted: false).group('departments.title').sum(:balance)
    @staff_nill_ledger_book_debit = StaffLedgerBook.group('staff_id').sum(:debit)
    @staff_nill_ledger_book_credit = StaffLedgerBook.group('staff_id').sum(:credit)
    @staff_nill_ledger_book_debit_total = StaffLedgerBook.where('debit > 0').where(staff_id: @staff_nill.ids).sum(:debit)
    @staff_nill_ledger_book_credit_total = StaffLedgerBook.where('credit > 0').where(staff_id: @staff_nill.ids).sum(:credit)
    respond_to do |format|
      format.js
    end
  end
  def trial_balance_accounts
    @all_user = SysUser.all
    @user_types = UserType.all
    @staff_names = Staff.all
    @sys_user_payable_group = SysUser.where('balance > 0').group(:user_group).sum(:balance)
    @sys_user_receiveable_group = SysUser.where('balance < 0').group(:user_group).sum(:balance)
    @departments = Department.all
    @q = Account.all.ransack(params[:q])
    @accounts = @q.result
    @account_debit = Payment.joins(:account).group(:title).sum(:debit)
    @account_credit = Payment.joins(:account).group(:title).sum(:credit)
    @account_debit_total = Payment.joins(:account).sum(:debit)
    @account_credit_total = Payment.joins(:account).sum(:credit)

    respond_to do |format|
      format.js
    end
  end
  def trial_balance_expense_reciveable
    @expense_total = ExpenseEntry.joins(:expense_type).sum(:amount)
    @expense_list = ExpenseEntry.joins(:expense_type).group('expense_types.id','expense_types.title').sum(:amount)

    @credit_expense = ExpenseEntry.joins(:payment).joins(:expense_type).group('expense_types.title').sum(:debit)
    @total_credit_expense = ExpenseEntry.joins(:payment).sum(:debit)

    respond_to do |format|
      format.js
    end
  end
  def trial_balance_purchase_reciveable
    @purchase_sale_detail_discount_list = PurchaseSaleDetail.where(transaction_type:'Sale').where.not(discount_price:[nil,0])
    @purchase_item_list = PurchaseSaleItem.joins(:item).where(transaction_type:'Purchase').group('items.title').having('sum(total_cost_price)>0').sum(:total_cost_price)
    @purchase_item_total = PurchaseSaleItem.joins(:item).where(transaction_type:'Purchase').sum(:total_cost_price)
    @purchase_product_list = PurchaseSaleItem.joins(:product).where(transaction_type:'Purchase').group('products.title').having('sum(total_cost_price)>0').sum(:total_cost_price)
    @purchase_product_total = PurchaseSaleItem.joins(:product).where(transaction_type:'Purchase').sum(:total_cost_price)
    respond_to do |format|
      format.js
    end
  end
  def trial_balance_sale_payable
    @sale_item_list = PurchaseSaleItem.joins(:item).where(transaction_type:'Sale').group('items.title').having('sum(total_sale_price)>0').sum(:total_sale_price)
    @sale_item_total = PurchaseSaleItem.joins(:item).where(transaction_type:'Sale').sum(:total_sale_price)
    @sale_product_list = PurchaseSaleItem.joins(:product).where(transaction_type:'Sale').group('products.title').having('sum(total_sale_price)>0').sum(:total_sale_price)
    @sale_product_total = PurchaseSaleItem.joins(:product).where(transaction_type:'Sale').sum(:total_sale_price)
    respond_to do |format|
      format.js
    end
  end
  def trial_balance_salary
    @pos_type_batha = pos_type_batha
    if @pos_type_batha.present?
      @salary_detail_list = SalaryDetail.joins(staff: :department).where(comment:["Payment Credit",nil]).where.not('departments.id>=4').group('departments.title').sum(:amount)
      @salary_detail_kharkar    = SalaryDetail.joins(staff: :department).where(comment:["Payment Credit",nil]).where('khakar_credit>0').where.not('departments.id=4').sum(:khakar_credit)
      @salary_detail_total = SalaryDetail.joins(staff: :department).where(comment:["Payment Credit",nil]).where.not('departments.id>=4').sum(:amount)+SalaryDetail.joins(staff: :department).where(comment:["Payment Credit",nil]).where('khakar_credit>0').where.not('departments.id=4').sum(:khakar_credit)
      @khakar_salary_detail_list = SalaryDetail.joins(staff: :department).where(comment:["Payment Credit",nil]).where('khakar_credit>0').where.not('departments.id=4').group('departments.title').sum(:khakar_credit)
    else
      @salary_detail_list = SalaryDetail.joins(staff: :department).where(comment:["Payment Credit",nil]).where.not('departments.id=4').group('departments.title').sum(:amount)
      @salary_detail_kharkar    = SalaryDetail.joins(staff: :department).where(comment:["Payment Credit",nil]).where('khakar_credit>0').where.not('departments.id=4').sum(:khakar_credit)
      @salary_detail_total = SalaryDetail.joins(staff: :department).where(comment:["Payment Credit",nil]).where.not('departments.id=4').sum(:amount)+SalaryDetail.joins(staff: :department).where(comment:["Payment Credit",nil]).where('khakar_credit>0').where.not('departments.id=4').sum(:khakar_credit)
      @khakar_salary_detail_list = SalaryDetail.joins(staff: :department).where(comment:["Payment Credit",nil]).where('khakar_credit>0').where.not('departments.id=4').group('departments.title').sum(:khakar_credit)
    end
    respond_to do |format|
      format.js
    end
  end

  # trial balance partialy data end

  def day_check
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
      if params[:sale].present?
        @q = PurchaseSaleDetail.includes(:purchase_sale_items).joins(:purchase_sale_items).where(:transaction_type=>"Sale").ransack(params[:q])
        @k = PurchaseSaleDetail.includes(:purchase_sale_items).joins(:purchase_sale_items).where(:transaction_type=>"Sale").ransack(params[:q])
      else
        @q = PurchaseSaleDetail.includes(:purchase_sale_items).joins(:purchase_sale_items).where(:transaction_type=>"Purchase").ransack(params[:q])
        @k = PurchaseSaleDetail.includes(:purchase_sale_items).joins(:purchase_sale_items).where(:transaction_type=>"Purchase").ransack(params[:q])
      end
    else
      if params[:sale].present?
        @q = PurchaseSaleDetail.includes(:purchase_sale_items).joins(:purchase_sale_items).where(:transaction_type=>"Sale").ransack(params[:q])
        @k = PurchaseSaleDetail.includes(:purchase_sale_items).joins(:purchase_sale_items).where(:transaction_type=>"Sale").ransack(params[:q])
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
      if params[:purchase_submit].present? or params[:sale_submit].present?
        product_id= params[:q][:purchase_sale_items_product_product_id].present? ? params[:q][:purchase_sale_items_product_product_id] : @products
        @sys_users = SysUser.all
        sys_user_id = params[:q][:sys_user_id_eq].present? ? params[:q][:sys_user_id_eq] : @sys_users
        staff =  params[:q][:staff_id_eq] if params[:q][:staff_id_eq].present?
        user_name =  params[:q][:user_name_eq] if params[:q][:user_name_eq].present?
        if params[:sale_submit].present?
          if staff
            if user_name
              @products_sale_price = PurchaseSaleDetail.joins(purchase_sale_items: :product).where(transaction_type: "Sale").where('purchase_sale_items.product_id':product_id).where(sys_user_id: sys_user_id,  'purchase_sale_items.created_at': @created_at_gteq.to_date.beginning_of_day..@created_at_lteq.to_date.end_of_day,transaction_type: "Sale",staff_id: staff, user_name: user_name).group(:title).sum(:sale_price)
              @products_sale = PurchaseSaleDetail.joins(purchase_sale_items: :product).where(transaction_type: "Sale").where('purchase_sale_items.product_id':product_id).where(sys_user_id: sys_user_id,  'purchase_sale_items.created_at': @created_at_gteq.to_date.beginning_of_day..@created_at_lteq.to_date.end_of_day,transaction_type: "Sale",staff_id: staff, user_name: user_name).group(:title).sum(:total_sale_price)
              @products_count = PurchaseSaleDetail.joins(purchase_sale_items: :product).where(transaction_type: "Sale").where('purchase_sale_items.product_id':product_id).where(sys_user_id: sys_user_id, 'purchase_sale_items.created_at': @created_at_gteq.to_date.beginning_of_day..@created_at_lteq.to_date.end_of_day,transaction_type: "Sale",staff_id: staff, user_name: user_name).group(:title).sum('purchase_sale_items.quantity')
              @products_sale_total = PurchaseSaleDetail.joins(purchase_sale_items: :product).where(transaction_type: "Sale").where('purchase_sale_items.product_id':product_id).where(sys_user_id: sys_user_id, 'purchase_sale_items.created_at': @created_at_gteq.to_date.beginning_of_day..@created_at_lteq.to_date.end_of_day,transaction_type: "Sale",staff_id: staff, user_name: user_name).sum(:total_sale_price)
            else
              @products_sale_price = PurchaseSaleDetail.joins(purchase_sale_items: :product).where(transaction_type: "Sale").where('purchase_sale_items.product_id':product_id).where(sys_user_id: sys_user_id,  'purchase_sale_items.created_at': @created_at_gteq.to_date.beginning_of_day..@created_at_lteq.to_date.end_of_day,transaction_type: "Sale",staff_id: staff).group(:title).sum(:sale_price)
              @products_sale = PurchaseSaleDetail.joins(purchase_sale_items: :product).where(transaction_type: "Sale").where('purchase_sale_items.product_id':product_id).where(sys_user_id: sys_user_id,  'purchase_sale_items.created_at': @created_at_gteq.to_date.beginning_of_day..@created_at_lteq.to_date.end_of_day,transaction_type: "Sale",staff_id: staff).group(:title).sum(:total_sale_price)
              @products_count = PurchaseSaleDetail.joins(purchase_sale_items: :product).where(transaction_type: "Sale").where('purchase_sale_items.product_id':product_id).where(sys_user_id: sys_user_id, 'purchase_sale_items.created_at': @created_at_gteq.to_date.beginning_of_day..@created_at_lteq.to_date.end_of_day,transaction_type: "Sale",staff_id: staff).group(:title).sum('purchase_sale_items.quantity')
              @products_sale_total = PurchaseSaleDetail.joins(purchase_sale_items: :product).where(transaction_type: "Sale").where('purchase_sale_items.product_id':product_id).where(sys_user_id: sys_user_id, 'purchase_sale_items.created_at': @created_at_gteq.to_date.beginning_of_day..@created_at_lteq.to_date.end_of_day,transaction_type: "Sale",staff_id: staff).sum(:total_sale_price)
            end
          else
            if user_name
              @products_sale_price = PurchaseSaleDetail.joins(purchase_sale_items: :product).where(transaction_type: "Sale").where('purchase_sale_items.product_id':product_id).where(sys_user_id: sys_user_id,  'purchase_sale_items.created_at': @created_at_gteq.to_date.beginning_of_day..@created_at_lteq.to_date.end_of_day,transaction_type: "Sale", user_name: user_name).group(:title).sum(:sale_price)
              @products_sale = PurchaseSaleDetail.joins(purchase_sale_items: :product).where(transaction_type: "Sale").where('purchase_sale_items.product_id':product_id).where(sys_user_id: sys_user_id,  'purchase_sale_items.created_at': @created_at_gteq.to_date.beginning_of_day..@created_at_lteq.to_date.end_of_day,transaction_type: "Sale", user_name: user_name).group(:title).sum(:total_sale_price)
              @products_count = PurchaseSaleDetail.joins(purchase_sale_items: :product).where(transaction_type: "Sale").where('purchase_sale_items.product_id':product_id).where(sys_user_id: sys_user_id, 'purchase_sale_items.created_at': @created_at_gteq.to_date.beginning_of_day..@created_at_lteq.to_date.end_of_day,transaction_type: "Sale", user_name: user_name).group(:title).sum('purchase_sale_items.quantity')
              @products_sale_total = PurchaseSaleDetail.joins(purchase_sale_items: :product).where(transaction_type: "Sale").where('purchase_sale_items.product_id':product_id).where(sys_user_id: sys_user_id, 'purchase_sale_items.created_at': @created_at_gteq.to_date.beginning_of_day..@created_at_lteq.to_date.end_of_day,transaction_type: "Sale", user_name: user_name).sum(:total_sale_price)
            else
              @products_sale_price = PurchaseSaleDetail.joins(purchase_sale_items: :product).where(transaction_type: "Sale").where('purchase_sale_items.product_id':product_id).where(sys_user_id: sys_user_id,  'purchase_sale_items.created_at': @created_at_gteq.to_date.beginning_of_day..@created_at_lteq.to_date.end_of_day,transaction_type: "Sale").group(:title).sum(:sale_price)
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
            @products_sale_price = PurchaseSaleDetail.joins(purchase_sale_items: :product).where('purchase_sale_items.product_id':product_id).where(sys_user_id: sys_user_id, created_at: @created_at_gteq.to_date.beginning_of_day..@created_at_lteq.to_date.end_of_day,transaction_type: "Purchase",staff_id: staff, user_name: user_name).group(:title).sum(:cost_price)
            @products_sale = PurchaseSaleDetail.joins(purchase_sale_items: :product).where('purchase_sale_items.product_id':product_id).where(sys_user_id: sys_user_id, created_at: @created_at_gteq.to_date.beginning_of_day..@created_at_lteq.to_date.end_of_day,transaction_type: "Purchase",staff_id: staff, user_name: user_name).group(:title).sum(:total_cost_price)
            @products_count = PurchaseSaleDetail.joins(purchase_sale_items: :product).where('purchase_sale_items.product_id':product_id).where(sys_user_id: sys_user_id, created_at: @created_at_gteq.to_date.beginning_of_day..@created_at_lteq.to_date.end_of_day,transaction_type: "Purchase",staff_id: staff, user_name: user_name).group(:title).sum('purchase_sale_items.quantity')
            @products_sale_total = PurchaseSaleDetail.joins(purchase_sale_items: :product).where('purchase_sale_items.product_id':product_id).where(sys_user_id: sys_user_id, created_at: @created_at_gteq.to_date.beginning_of_day..@created_at_lteq.to_date.end_of_day,transaction_type: "Purchase",staff_id: staff, user_name: user_name).sum(:total_cost_price)
            @product_carriage = PurchaseSaleDetail.where(sys_user_id: sys_user_id,created_at: @created_at_gteq.to_date.beginning_of_day..@created_at_lteq.to_date.end_of_day,transaction_type: "Purchase",staff_id: staff, user_name: user_name).sum(:carriage)
            @product_loading = PurchaseSaleDetail.where(sys_user_id: sys_user_id,created_at: @created_at_gteq.to_date.beginning_of_day..@created_at_lteq.to_date.end_of_day,transaction_type: "Purchase",staff_id: staff, user_name: user_name).sum(:loading)
          else
            @products_sale_price = PurchaseSaleDetail.joins(purchase_sale_items: :product).where('purchase_sale_items.product_id':product_id).where(sys_user_id: sys_user_id, created_at: @created_at_gteq.to_date.beginning_of_day..@created_at_lteq.to_date.end_of_day,transaction_type: "Purchase",staff_id: staff).group(:title).sum(:cost_price)
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
              render pdf: "Day-Out",
              layout: 'pdf.html',
              page_size: 'A4',
              margin_top: '0',
              margin_right: '0',
              margin_bottom: '0',
              margin_left: '0',
              footer:  {             # optional, use 'pdf_plain' for a pdf_plain.html.pdf.erb file, defaults to main layout
                right: '[page] of [topage]'},
              encoding: "UTF-8",
              show_as_html: false
            end
          end
        else
          respond_to do |format|
            request.format = 'pdf'
            format.html
            format.pdf do
              @pos_setting=PosSetting.first
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
      end
      if params[:submit_pdf_staff_without].present? or params[:submit_pdf_staff_without].present? or params[:email].present?
        product_id= params[:q][:purchase_sale_items_product_product_id].present? ? params[:q][:purchase_sale_items_product_product_id] : @products
        @sys_users = SysUser.all
        sys_user_id = params[:q][:sys_user_id_eq].present? ? params[:q][:sys_user_id_eq] : @sys_users
        user_name =  params[:q][:user_name_eq] if params[:q][:user_name_eq].present?
        if params[:submit_pdf_staff_without].present? or params[:email].present?
          if staff
            if user_name
              @products_sale_price =  PurchaseSaleItem.joins(:purchase_sale_detail,:product).where(product_id:product_id, created_at: @created_at_gteq.to_date.beginning_of_day..@created_at_lteq.to_date.end_of_day,transaction_type: "Sale",'purchase_sale_details.staff_id': staff, 'purchase_sale_details.user_name': user_name).group(:title).sum(:sale_price)
              @products_sale =  PurchaseSaleItem.joins(:purchase_sale_detail,:product).where(product_id:product_id, created_at: @created_at_gteq.to_date.beginning_of_day..@created_at_lteq.to_date.end_of_day,transaction_type: "Sale",'purchase_sale_details.staff_id': staff, 'purchase_sale_details.user_name': user_name).group(:title).sum(:total_sale_price)
              @products_count = PurchaseSaleItem.joins(:purchase_sale_detail,:product).where(product_id:product_id, created_at: @created_at_gteq.to_date.beginning_of_day..@created_at_lteq.to_date.end_of_day,transaction_type: "Sale",'purchase_sale_details.staff_id': staff, 'purchase_sale_details.user_name': user_name).group(:title).sum('purchase_sale_items.quantity')
              @products_group = PurchaseSaleDetail.joins(purchase_sale_items: :product).where(sys_user_id: sys_user_id, created_at: @created_at_gteq.to_date.beginning_of_day..@created_at_lteq.to_date.end_of_day,transaction_type: "Sale",staff_id: staff, user_name: user_name).group(:title).sum('purchase_sale_items.quantity')
              @products_group_count = PurchaseSaleDetail.joins(purchase_sale_items: :product).where(sys_user_id: sys_user_id, created_at: @created_at_gteq.to_date.beginning_of_day..@created_at_lteq.to_date.end_of_day,transaction_type: "Sale",staff_id: staff, user_name: user_name).sum('purchase_sale_items.quantity')
            else
              @products_sale_price =  PurchaseSaleItem.joins(:purchase_sale_detail,:product).where(product_id:product_id, created_at: @created_at_gteq.to_date.beginning_of_day..@created_at_lteq.to_date.end_of_day,transaction_type: "Sale",'purchase_sale_details.staff_id': staff).group(:title).sum(:sale_price)
              @products_sale =  PurchaseSaleItem.joins(:purchase_sale_detail,:product).where(product_id:product_id, created_at: @created_at_gteq.to_date.beginning_of_day..@created_at_lteq.to_date.end_of_day,transaction_type: "Sale",'purchase_sale_details.staff_id': staff).group(:title).sum(:total_sale_price)
              @products_count = PurchaseSaleItem.joins(:purchase_sale_detail,:product).where(product_id:product_id, created_at: @created_at_gteq.to_date.beginning_of_day..@created_at_lteq.to_date.end_of_day,transaction_type: "Sale",'purchase_sale_details.staff_id': staff).group(:title).sum('purchase_sale_items.quantity')
              @products_group = PurchaseSaleDetail.joins(purchase_sale_items: :product).where(sys_user_id: sys_user_id, created_at: @created_at_gteq.to_date.beginning_of_day..@created_at_lteq.to_date.end_of_day,transaction_type: "Sale",staff_id: staff).group(:title).sum('purchase_sale_items.quantity')
              @products_group_count = PurchaseSaleDetail.joins(purchase_sale_items: :product).where(sys_user_id: sys_user_id, created_at: @created_at_gteq.to_date.beginning_of_day..@created_at_lteq.to_date.end_of_day,transaction_type: "Sale",staff_id: staff).sum('purchase_sale_items.quantity')
            end
          else
            if user_name
              @products_sale_price =  PurchaseSaleItem.joins(:purchase_sale_detail,:product).where(product_id:product_id, created_at: @created_at_gteq.to_date.beginning_of_day..@created_at_lteq.to_date.end_of_day,transaction_type: "Sale", 'purchase_sale_details.user_name': user_name).group(:title).sum(:sale_price)
              @products_sale =  PurchaseSaleItem.joins(:purchase_sale_detail,:product).where(product_id:product_id, created_at: @created_at_gteq.to_date.beginning_of_day..@created_at_lteq.to_date.end_of_day,transaction_type: "Sale", 'purchase_sale_details.user_name': user_name).group(:title).sum(:total_sale_price)
              @products_count = PurchaseSaleItem.joins(:purchase_sale_detail,:product).where(product_id:product_id, created_at: @created_at_gteq.to_date.beginning_of_day..@created_at_lteq.to_date.end_of_day,transaction_type: "Sale", 'purchase_sale_details.user_name': user_name).group(:title).sum('purchase_sale_items.quantity')
              @products_group = PurchaseSaleDetail.joins(purchase_sale_items: :product).where(sys_user_id: sys_user_id, created_at: @created_at_gteq.to_date.beginning_of_day..@created_at_lteq.to_date.end_of_day,transaction_type: "Sale", user_name: user_name).group(:title).sum('purchase_sale_items.quantity')
              @products_group_count = PurchaseSaleDetail.joins(purchase_sale_items: :product).where(sys_user_id: sys_user_id, created_at: @created_at_gteq.to_date.beginning_of_day..@created_at_lteq.to_date.end_of_day,transaction_type: "Sale", user_name: user_name).sum('purchase_sale_items.quantity')
            else
              @products_sale_price =  PurchaseSaleItem.joins(:purchase_sale_detail,:product).where(product_id:product_id, created_at: @created_at_gteq.to_date.beginning_of_day..@created_at_lteq.to_date.end_of_day,transaction_type: "Sale").group(:title).sum(:sale_price)
              @products_sale =  PurchaseSaleItem.joins(:purchase_sale_detail,:product).where(product_id:product_id, created_at: @created_at_gteq.to_date.beginning_of_day..@created_at_lteq.to_date.end_of_day,transaction_type: "Sale").group(:title).sum(:total_sale_price)
              @products_count = PurchaseSaleItem.joins(:purchase_sale_detail,:product).where(product_id:product_id, created_at: @created_at_gteq.to_date.beginning_of_day..@created_at_lteq.to_date.end_of_day,transaction_type: "Sale").group(:title).sum('purchase_sale_items.quantity')
              @products_group = PurchaseSaleDetail.joins(purchase_sale_items: :product).where(sys_user_id: sys_user_id, created_at: @created_at_gteq.to_date.beginning_of_day..@created_at_lteq.to_date.end_of_day,transaction_type: "Sale").group(:title).sum('purchase_sale_items.quantity')
              @products_group_count = PurchaseSaleDetail.joins(purchase_sale_items: :product).where(sys_user_id: sys_user_id, created_at: @created_at_gteq.to_date.beginning_of_day..@created_at_lteq.to_date.end_of_day,transaction_type: "Sale").sum('purchase_sale_items.quantity')
            end
          end
        else
          if staff
            if user_name
              @products_sale_price =  PurchaseSaleItem.joins(:product).where(product_id:product_id, created_at: @created_at_gteq.to_date.beginning_of_day..@created_at_lteq.to_date.end_of_day,'purchase_sale_details.staff_id': staff).group(:title).sum(:cost_price)
              @products_sale =  PurchaseSaleItem.joins(:product).where(product_id:product_id, created_at: @created_at_gteq.to_date.beginning_of_day..@created_at_lteq.to_date.end_of_day,'purchase_sale_details.staff_id': staff).group(:title).sum(:total_cost_price)
              @products_sale_total =  PurchaseSaleItem.joins(:product).where(product_id:product_id, created_at: @created_at_gteq.to_date.beginning_of_day..@created_at_lteq.to_date.end_of_day,'purchase_sale_details.staff_id': staff).sum(:total_cost_price)
              @products_count = PurchaseSaleItem.joins(:product).where(product_id:product_id, created_at: @created_at_gteq.to_date.beginning_of_day..@created_at_lteq.to_date.end_of_day,transaction_type: "Purchase",'purchase_sale_details.staff_id': staff).group(:title).sum('purchase_sale_items.quantity')
            else
              @products_sale_price =  PurchaseSaleItem.joins(:product).where(product_id:product_id, created_at: @created_at_gteq.to_date.beginning_of_day..@created_at_lteq.to_date.end_of_day,'purchase_sale_details.staff_id': staff).group(:title).sum(:cost_price)
              @products_sale =  PurchaseSaleItem.joins(:product).where(product_id:product_id, created_at: @created_at_gteq.to_date.beginning_of_day..@created_at_lteq.to_date.end_of_day,'purchase_sale_details.staff_id': staff).group(:title).sum(:total_cost_price)
              @products_sale_total =  PurchaseSaleItem.joins(:product).where(product_id:product_id, created_at: @created_at_gteq.to_date.beginning_of_day..@created_at_lteq.to_date.end_of_day,'purchase_sale_details.staff_id': staff).sum(:total_cost_price)
              @products_count = PurchaseSaleItem.joins(:product).where(product_id:product_id, created_at: @created_at_gteq.to_date.beginning_of_day..@created_at_lteq.to_date.end_of_day,transaction_type: "Purchase",'purchase_sale_details.staff_id': staff).group(:title).sum('purchase_sale_items.quantity')
            end
          else
            if user_name
              @products_sale_price =  PurchaseSaleItem.joins(:product).where(product_id:product_id, created_at: @created_at_gteq.to_date.beginning_of_day..@created_at_lteq.to_date.end_of_day).group(:title).sum(:cost_price)
              @products_sale =  PurchaseSaleItem.joins(:product).where(product_id:product_id, created_at: @created_at_gteq.to_date.beginning_of_day..@created_at_lteq.to_date.end_of_day).group(:title).sum(:total_cost_price)
              @products_sale_total =  PurchaseSaleItem.joins(:product).where(product_id:product_id, created_at: @created_at_gteq.to_date.beginning_of_day..@created_at_lteq.to_date.end_of_day).sum(:total_cost_price)
              @products_count = PurchaseSaleItem.joins(:product).where(product_id:product_id, created_at: @created_at_gteq.to_date.beginning_of_day..@created_at_lteq.to_date.end_of_day,transaction_type: "Purchase").group(:title).sum('purchase_sale_items.quantity')
            else
              @products_sale_price =  PurchaseSaleItem.joins(:product).where(product_id:product_id, created_at: @created_at_gteq.to_date.beginning_of_day..@created_at_lteq.to_date.end_of_day).group(:title).sum(:cost_price)
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
          respond_to do |format|
            request.format = 'pdf'
            format.html
            format.pdf do
              @pos_setting=PosSetting.first
              @purchase_sale_details_pdf = @q.result
              render pdf: "index_batha",
              layout: 'index_batha.pdf',
              page_size: 'A4',
              margin_top: '0',
              margin_right: '0',
              margin_bottom: '0',
              margin_left: '0',
              footer:  {             # optional, use 'pdf_plain' for a pdf_plain.html.pdf.erb file, defaults to main layout
                right: '[page] of [topage]'},
              encoding: "UTF-8",
              show_as_html: false
            end
          end
        end

      end
  end

  def day_out_report
    @departments=Department.all
    @raw_products = RawProduct.all
    @book_date_gteq = DateTime.now
    @book_date_lteq = DateTime.now
    @departments=Department.all
    @raw_products = RawProduct.all



    if params[:q].present?
      @department = params[:q][:department_id]
      @book_date_gteq = params[:q][:book_date_gteq] if params[:q][:book_date_gteq].present?
      @book_date_lteq = params[:q][:book_date_lteq] if params[:q][:book_date_lteq].present?
    end

    # Sale Sum Data
    @products_sale_price = PurchaseSaleDetail.joins(purchase_sale_items: :product).where(transaction_type: "Sale").where('purchase_sale_items.created_at': @book_date_gteq.to_date.beginning_of_day..@book_date_lteq.to_date.end_of_day,transaction_type: "Sale").group(:title).sum('(sale_price/purchase_sale_items.quantity)*100')
    @products_sale = PurchaseSaleDetail.joins(purchase_sale_items: :product).where(transaction_type: "Sale").where('purchase_sale_items.created_at': @book_date_gteq.to_date.beginning_of_day..@book_date_lteq.to_date.end_of_day,transaction_type: "Sale").group(:title).sum(:total_sale_price)
    @products_sale_count = PurchaseSaleDetail.joins(purchase_sale_items: :product).where(transaction_type: "Sale").where('purchase_sale_items.created_at': @book_date_gteq.to_date.beginning_of_day..@book_date_lteq.to_date.end_of_day,transaction_type: "Sale").group(:title).sum('purchase_sale_items.quantity')
    @products_sale_total = PurchaseSaleDetail.joins(purchase_sale_items: :product).where(transaction_type: "Sale").where('purchase_sale_items.created_at': @book_date_gteq.to_date.beginning_of_day..@book_date_lteq.to_date.end_of_day,transaction_type: "Sale").sum(:total_sale_price)

    @product_sale_carriage = PurchaseSaleDetail.joins(purchase_sale_items: :product).where('purchase_sale_items.created_at': @book_date_gteq.to_date.beginning_of_day..@book_date_lteq.to_date.end_of_day,transaction_type: "Sale").sum(:carriage)
    @product_sale_loading = PurchaseSaleDetail.joins(purchase_sale_items: :product).where('purchase_sale_items.created_at': @book_date_gteq.to_date.beginning_of_day..@book_date_lteq.to_date.end_of_day,transaction_type: "Sale").sum(:loading)

    # Purchase Sum Data
    @products_purchase_price = PurchaseSaleDetail.joins(purchase_sale_items: :product).where(transaction_type: "Purchase").where('purchase_sale_items.created_at': @book_date_gteq.to_date.beginning_of_day..@book_date_lteq.to_date.end_of_day,transaction_type: "Purchase").group(:title).sum('(cost_price/purchase_sale_items.quantity)*100')
    @products_purchase = PurchaseSaleDetail.joins(purchase_sale_items: :product).where(transaction_type: "Purchase").where('purchase_sale_items.created_at': @book_date_gteq.to_date.beginning_of_day..@book_date_lteq.to_date.end_of_day,transaction_type: "Purchase").group(:title).sum(:total_cost_price)
    @products_purchase_count = PurchaseSaleDetail.joins(purchase_sale_items: :product).where(transaction_type: "Purchase").where('purchase_sale_items.created_at': @book_date_gteq.to_date.beginning_of_day..@book_date_lteq.to_date.end_of_day,transaction_type: "Purchase").group(:title).sum('purchase_sale_items.quantity')
    @products_purchase_total = PurchaseSaleDetail.joins(purchase_sale_items: :product).where(transaction_type: "Purchase").where('purchase_sale_items.created_at': @book_date_gteq.to_date.beginning_of_day..@book_date_lteq.to_date.end_of_day,transaction_type: "Purchase").sum(:total_cost_price)

    @product_purchase_carriage = PurchaseSaleDetail.joins(purchase_sale_items: :product).where('purchase_sale_items.created_at': @book_date_gteq.to_date.beginning_of_day..@book_date_lteq.to_date.end_of_day,transaction_type: "Purchase").sum(:carriage)
    @product_purchase_loading = PurchaseSaleDetail.joins(purchase_sale_items: :product).where('purchase_sale_items.created_at': @book_date_gteq.to_date.beginning_of_day..@book_date_lteq.to_date.end_of_day,transaction_type: "Purchase").sum(:loading)

    #Expense Sum Data
    @expense_entries = ExpenseEntry.where(created_at: @book_date_gteq.to_date.beginning_of_day..@book_date_lteq.to_date.end_of_day).group(:expense_type_id).sum(:amount)
    @expense_total = ExpenseEntry.where(created_at: @book_date_gteq.to_date.beginning_of_day..@book_date_lteq.to_date.end_of_day).sum(:amount)

    #LedgerBook Sum Data
    @ledger_book_debit = LedgerBook.where(created_at: @book_date_gteq.to_date.beginning_of_day..@book_date_lteq.to_date.end_of_day).group(:sys_user).sum(:debit)
    @ledger_book_credit = LedgerBook.where(created_at: @book_date_gteq.to_date.beginning_of_day..@book_date_lteq.to_date.end_of_day).group(:sys_user).sum(:credit)
    @ledger_book_total_debit = LedgerBook.where(created_at: @book_date_gteq.to_date.beginning_of_day..@book_date_lteq.to_date.end_of_day).sum(:debit)
    @ledger_book_total_credit = LedgerBook.where(created_at: @book_date_gteq.to_date.beginning_of_day..@book_date_lteq.to_date.end_of_day).sum(:credit)

    #StaffBook Sum Data
    @staff_ledger_book_debit = StaffLedgerBook.where(created_at: @book_date_gteq.to_date.beginning_of_day..@book_date_lteq.to_date.end_of_day).group(:staff).sum(:debit)
    @staff_ledger_book_credit = StaffLedgerBook.where(created_at: @book_date_gteq.to_date.beginning_of_day..@book_date_lteq.to_date.end_of_day).group(:staff).sum(:credit)
    @staff_ledger_book_total_debit = StaffLedgerBook.where(created_at: @book_date_gteq.to_date.beginning_of_day..@book_date_lteq.to_date.end_of_day).sum(:debit)
    @staff_ledger_book_total_credit = StaffLedgerBook.where(created_at: @book_date_gteq.to_date.beginning_of_day..@book_date_lteq.to_date.end_of_day).sum(:credit)
    @q = Product.ransack(params[:q])
    if pos_type_batha.present?
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
    end

  end

  def chart
    # @expense_by_month = Hash.new
    # @expense_types = ExpenseType.order(:title).pluck(:title)
    # @total_expense_year_month = ExpenseEntry.order(:created_at).group_by { |m| m.created_at.strftime("%m/%Y") }
    # @expense_by_year_month = ExpenseEntry.joins(:expense_type).group('YEAR(expense_entries.created_at)').group('MONTH(expense_entries.created_at)').group(:title).order('2 ASC, 3 ASC, 4 ASC').sum(:amount)
    # @total_expense_year_month.each do |ym|
    #   month = ym.first.split('/').first.to_i
    #   year = ym.first.split('/').second.to_i
    #   @expense_by_month[[year,month]] = @expense_by_year_month.select{|t| t[0] == year && t[1] == month}
    # end

    if params[:from].present?
      @paid_to_month = params[:from][:month].present? ? params[:from][:month].to_i : Date.today.month
      @paid_to_year =  params[:from][:year].present? ? params[:from][:year].to_i : Date.today.year
      months = 12
    else
      @paid_to_month = Date.today.month
      @paid_to_year = Date.today.year
      oldest_expense = Expense.order(:created_at)&.first&.created_at&.strftime("%Y").to_i
      oldest_month = oldest_expense == 0 ? @paid_to_year : oldest_expense
      oldest_expense_entry = ExpenseEntry.order(:created_at)&.first&.created_at&.strftime("%Y").to_i
      oldest_month = oldest_expense_entry == 0 ? @paid_to_year : oldest_expense_entry
      oldest_investment = Investment.order(:created_at)&.first&.created_at&.strftime("%Y").to_i
      oldest_month = oldest_investment == 0 ? @paid_to_year : oldest_investment
      oldest_purchase_sale_detail = PurchaseSaleDetail.order(:created_at)&.first&.created_at&.strftime("%Y").to_i
      oldest_month = oldest_purchase_sale_detail == 0 ? @paid_to_year : oldest_purchase_sale_detail
      oldest_salary = Salary.order(:created_at)&.first&.created_at&.strftime("%Y").to_i
      oldest_month = oldest_salary == 0 ? @paid_to_year : oldest_salary
      months = Date.today.year-oldest_month
      months = (months+1)*12
    end
    @account_list=Account.all
    @accounts = Hash.new
    @suppliers=SysUser.where(:user_group=>['Supplier','Both']).ransack(params[:q]).result
    (1..months).each do |i|
      @paid_to_month == 0 ? @paid_to_month = 12 : @paid_to_month
      @accounts[[Date::ABBR_MONTHNAMES[@paid_to_month],@paid_to_year]] =
      Expense.where("extract(month from created_at)=? AND extract(year from created_at) = ?", @paid_to_month, @paid_to_year).group(:account_id).sum(:expense),
      ExpenseEntry.where("extract(month from expense_entries.created_at)=? AND extract(year from expense_entries.created_at) = ?", @paid_to_month, @paid_to_year).group(:account_id).sum(:amount),
      Investment.where("extract(month from created_at)=? AND extract(year from created_at) = ?", @paid_to_month, @paid_to_year).group(:account_id).sum(:debit),
      PurchaseSaleDetail.where("extract(month from created_at)=? AND extract(year from created_at) = ?", @paid_to_month, @paid_to_year).where(transaction_type: "Purchase").where(sys_user_id: @suppliers).group(:account_id).sum(:total_bill),
      Salary.where("extract(month from created_at)=? AND extract(year from created_at) = ?", @paid_to_month, @paid_to_year).group(:account_id).sum(:paid_salary),
      Salary.where("extract(month from created_at)=? AND extract(year from created_at) = ?", @paid_to_month, @paid_to_year).group(:account_id).sum(:advance)
      @paid_to_month = @paid_to_month - 1
      @paid_to_month == 0 ? @paid_to_year = @paid_to_year-1 : @paid_to_year
    end
    @total_fee_without = Staff.sum(:monthly_salary)
    @collected_fee = Salary.where("extract(month from created_at)=? AND extract(year from created_at) = ?", @paid_to_month, @paid_to_year).sum(:paid_salary)
    @expected_exp = Staff.all.sum(:monthly_salary)
    @actual_exp = Salary.where("extract(month from created_at)=? AND extract(year from created_at) = ?", @paid_to_month, @paid_to_year).sum(:paid_salary)+
    Expense.where("extract(month from created_at)=? AND extract(year from created_at) = ?", @paid_to_month, @paid_to_year).sum(:expense)
    if params[:from].present?
      @paid_to_month = params[:from][:month].present? ? params[:from][:month].to_i : Date.today.month
      @paid_to_year =  params[:from][:year].present? ? params[:from][:year].to_i : Date.today.year
    else
      @paid_to_month = Date.today.month
      @paid_to_year = Date.today.year
    end
    @revenue=Hash.new
    (1..months).each do |i|
      @paid_to_month == 0 ? @paid_to_month = 12 : @paid_to_month
      @revenue[[Date::ABBR_MONTHNAMES[@paid_to_month],@paid_to_year]] =
      PurchaseSaleDetail.where("extract(month from created_at)=? AND extract(year from created_at) = ?",@paid_to_month, @paid_to_year).where(transaction_type: "Sale").sum(:total_bill),
      DailySale.where("extract(month from created_at)=? AND extract(year from created_at) = ?", @paid_to_month, @paid_to_year).sum(:cash_out)
      @paid_to_month = @paid_to_month - 1
      @paid_to_month == 0 ? @paid_to_year = @paid_to_year-1 : @paid_to_year
    end
    @revenue=@revenue.to_a.reverse.to_h

    if params[:from].present?
      @paid_to_month = params[:from][:month].present? ? params[:from][:month].to_i : Date.today.month
      @paid_to_year =  params[:from][:year].present? ? params[:from][:year].to_i : Date.today.year
    else
      @paid_to_month = Date.today.month
      @paid_to_year = Date.today.year
    end
    @expense=Hash.new
    (1..months).each do |i|
      @paid_to_month == 0 ? @paid_to_month = 12 : @paid_to_month
      @expense[[Date::ABBR_MONTHNAMES[@paid_to_month],@paid_to_year]] =
      Salary.where("extract(month from created_at)=? AND extract(year from created_at) = ?", @paid_to_month, @paid_to_year).sum(:advance)+
      Salary.where("extract(month from created_at)=?  AND extract(year from created_at) = ?", @paid_to_month, @paid_to_year).sum(:paid_salary)+
      Expense.where("extract(month from created_at)=?  AND extract(year from created_at) = ?", @paid_to_month, @paid_to_year).sum(:expense)+
      PurchaseSaleDetail.where("extract(month from created_at)=?  AND extract(year from created_at) = ?", @paid_to_month, @paid_to_year).where(transaction_type: "Purchase").where(sys_user_id: @suppliers).sum(:total_bill)
      @paid_to_month = @paid_to_month - 1
      @paid_to_month == 0 ? @paid_to_year = @paid_to_year-1 : @paid_to_year
    end
    @expense=@expense.to_a.reverse.to_h
    if params[:from].present?
      @paid_to_month = params[:from][:month].present? ? params[:from][:month].to_i : Date.today.month
      @paid_to_year =  params[:from][:year].present? ? params[:from][:year].to_i : Date.today.year
    else
      @paid_to_month = Date.today.month
      @paid_to_year = Date.today.year
    end
    @investment=Hash.new
    (1..months).each do |i|
      @paid_to_month == 0 ? @paid_to_month = 12 : @paid_to_month
      @investment[[Date::ABBR_MONTHNAMES[@paid_to_month],@paid_to_year]] = Investment.where("extract(month from created_at)=? AND extract(year from created_at) = ?", @paid_to_month, @paid_to_year).sum(:debit)
      @paid_to_month = @paid_to_month - 1
      @paid_to_month == 0 ? @paid_to_year = @paid_to_year-1 : @paid_to_year
    end
    @investment=@investment.to_a.reverse.to_h

    if params[:from].present?
      @paid_to_month = params[:from][:month].present? ? params[:from][:month].to_i : Date.today.month
      @paid_to_year =  params[:from][:year].present? ? params[:from][:year].to_i : Date.today.year
    else
      @paid_to_month = Date.today.month
      @paid_to_year = Date.today.year
    end
    @expense_by_type=Hash.new
    @expense_by_type_month=Array.new
    @total_salary=0
    @purchase_sale_detail=0
    @investment_month=0
    (1..months).each do |i|
      @paid_to_month == 0 ? @paid_to_month = 12 : @paid_to_month
      total_salary = Salary.where("extract(month from created_at)=? AND extract(year from created_at) = ?", @paid_to_month, @paid_to_year).sum(:paid_salary)+Salary.where("extract(month from created_at)=? AND extract(year from created_at) = ?", @paid_to_month, @paid_to_year).sum(:advance)
      purchase_sale_detail = PurchaseSaleDetail.where("extract(month from created_at)=? AND extract(year from created_at) = ?", @paid_to_month, @paid_to_year).where(transaction_type: "Purchase").where(sys_user_id: @suppliers).sum(:total_bill)
      investment=Investment.where("extract(month from created_at)=? AND extract(year from created_at) = ?", @paid_to_month, @paid_to_year).sum(:debit)
      @total_salary=@total_salary+total_salary
      @investment_month=@investment_month+investment
      @purchase_sale_detail=@purchase_sale_detail+purchase_sale_detail
      @expense_by_type_month<< total_salary+purchase_sale_detail+investment+Expense.joins(:expense_type).where("extract(month from expenses.created_at)=? AND extract(year from expenses.created_at) = ?", @paid_to_month, @paid_to_year).sum(:expense)+ExpenseEntry.joins(:expense_type).where("extract(month from expense_entries.created_at)=? AND extract(year from expense_entries.created_at) = ?", @paid_to_month, @paid_to_year).sum(:amount)
      @expense_by_type[[Date::ABBR_MONTHNAMES[@paid_to_month],@paid_to_year]] =
      total_salary,
      Expense.joins(:expense_type).where("extract(month from expenses.created_at)=? AND extract(year from expenses.created_at) = ?", @paid_to_month, @paid_to_year).group(:title).sum(:expense),
      ExpenseEntry.joins(:expense_type).where("extract(month from expense_entries.created_at)=? AND extract(year from expense_entries.created_at) = ?", @paid_to_month, @paid_to_year).group(:title).sum(:amount),
      purchase_sale_detail,
      investment
      @paid_to_month = @paid_to_month - 1
      @paid_to_month == 0 ? @paid_to_year = @paid_to_year-1 : @paid_to_year
    end
    if params[:from].present?
      @paid_to_month = params[:from][:month].present? ? params[:from][:month].to_i : Date.today.month
      @paid_to_year =  params[:from][:year].present? ? params[:from][:year].to_i : Date.today.year
    else
      @paid_to_month = Date.today.month
      @paid_to_year = Date.today.year
    end
    @lastday=Time.days_in_month(@paid_to_month, @paid_to_year)
    @expense_by_day=Hash.new
    @expense_by_day_list=Array.new
    @total_salary_day=0
    @purchase_sale_detail_day=0
    @investment_day=0
    @expense_day=Array.new
    (1..@lastday).each do |i|
      total_salary=Salary.where("extract(day from created_at)=? AND extract(month from created_at)=? AND extract(year from created_at) = ?",i, @paid_to_month, @paid_to_year).sum(:paid_salary)+Salary.where("extract(day from created_at)=? AND extract(month from created_at)=? AND extract(year from created_at) = ?",i, @paid_to_month, @paid_to_year).sum(:advance)
      purchase_sale_detail=PurchaseSaleDetail.where("extract(day from created_at)=? AND extract(month from created_at)=? AND extract(year from created_at) = ?",i, @paid_to_month, @paid_to_year).where(transaction_type: "Purchase").where(sys_user_id: @suppliers).sum(:total_bill)
      investment=Investment.where("extract(day from created_at)=? AND extract(month from created_at)=? AND extract(year from created_at) = ?",i, @paid_to_month, @paid_to_year).sum(:debit)
      @expense_day=Expense.joins(:expense_type).where("extract(day from expenses.created_at)=? AND extract(month from expenses.created_at)=? AND extract(year from expenses.created_at) = ?",i, @paid_to_month, @paid_to_year).sum(:expense)+ExpenseEntry.joins(:expense_type).where("extract(day from expense_entries.created_at)=? AND extract(month from expense_entries.created_at)=? AND extract(year from expense_entries.created_at) = ?",i, @paid_to_month, @paid_to_year).sum(:amount)
      @total_salary_day=@total_salary_day+total_salary
      @purchase_sale_detail_day=@purchase_sale_detail_day+purchase_sale_detail
      @investment_day=@investment_day+investment
      @expense_by_day_list << @investment_day+@purchase_sale_detail_day+@total_salary_day+@expense_day
      @expense_by_day[i] =
      total_salary,
      Expense.joins(:expense_type).where("extract(day from expenses.created_at)=? AND extract(month from expenses.created_at)=? AND extract(year from expenses.created_at) = ?",i, @paid_to_month, @paid_to_year).group(:title).sum(:expense),
      ExpenseEntry.joins(:expense_type).where("extract(day from expense_entries.created_at)=? AND extract(month from expense_entries.created_at)=? AND extract(year from expense_entries.created_at) = ?",i, @paid_to_month, @paid_to_year).group(:title).sum(:amount),
      purchase_sale_detail,
      investment
    end

    if params[:from].present?
      @paid_to_month = params[:from][:month].present? ? params[:from][:month].to_i : Date.today.month
      @paid_to_year =  params[:from][:year].present? ? params[:from][:year].to_i : Date.today.year
    else
      @paid_to_month = Date.today.month
      @paid_to_year = Date.today.year
    end
    @revenue_by_type=Hash.new
    (1..months).each do |i|
      @paid_to_month == 0 ? @paid_to_month = 12 : @paid_to_month
      @revenue_by_type[[Date::ABBR_MONTHNAMES[@paid_to_month],@paid_to_year]] = PurchaseSaleDetail.where("extract(month from created_at)=? AND extract(year from created_at) = ?", @paid_to_month, @paid_to_year).where(transaction_type: "Sale").sum(:total_bill),DailySale.where("extract(month from created_at)=? AND extract(year from created_at) = ?", @paid_to_month, @paid_to_year).sum(:cash_out)
      @paid_to_month = @paid_to_month - 1
      @paid_to_month == 0 ? @paid_to_year = @paid_to_year-1 : @paid_to_year
    end

    if params[:from].present?
      @paid_to_month = params[:from][:month].present? ? params[:from][:month].to_i : Date.today.month
      @paid_to_year =  params[:from][:year].present? ? params[:from][:year].to_i : Date.today.year
    else
      @paid_to_month = Date.today.month
      @paid_to_year = Date.today.year
    end
    @lastday=Time.days_in_month(@paid_to_month, @paid_to_year)
    @revenue_by_day=Hash.new
    (1..@lastday).each do |i|
      @revenue_by_day[i] = PurchaseSaleDetail.where("extract(day from created_at)=? AND extract(month from created_at)=? AND extract(year from created_at) = ?",i, @paid_to_month, @paid_to_year).where(transaction_type: "Sale").sum(:total_bill),DailySale.where("extract(day from created_at)=? AND extract(month from created_at)=? AND extract(year from created_at) = ?",i, @paid_to_month, @paid_to_year).sum(:cash_out)
    end


    if params[:submit_pdf].present?
      request.format = 'pdf'
      respond_to do |format|
        format.html
        format.pdf do
          render pdf: 'index_staff_wise',
          layout: 'pdf.html',
          orientation: 'Landscape',
          page_size: 'A4',
          margin_top: '0',
          margin_right: '0',
          margin_bottom: '0',
          margin_left: '0',
          footer:  {             # optional, use 'pdf_plain' for a pdf_plain.html.pdf.erb file, defaults to main layout
            right: '[page] of [topage]'},
          encoding: "UTF-8",
          show_as_html: false
        end
      end
    end

  end

  def product_report
    @created_at_gteq = DateTime.current.beginning_of_month
    @created_at_lteq = DateTime.now
    @products = Product.all
    @products_list=''
    @purchase_item = PurchaseSaleItem.includes(:product).where(transaction_type: "Sale", created_at: @created_at_gteq.to_date.beginning_of_day..@created_at_lteq.to_date.end_of_day).group("product_id").order('products.title asc').pluck("products.title,SUM(quantity),SUM(total_cost_price),SUM(total_sale_price),SUM(discount_price),SUM(gst_amount)")
    @purchase_discount = PurchaseSaleDetail .where(transaction_type: "Sale", created_at: @created_at_gteq.to_date.beginning_of_day..@created_at_lteq.to_date.end_of_day).sum(:discount_price)
    @total_all = PurchaseSaleItem.includes(:product).where(transaction_type: "Sale", created_at: @created_at_gteq.to_date.beginning_of_day..@created_at_lteq.to_date.end_of_day).pluck("SUM(quantity),SUM(total_cost_price),SUM(total_sale_price),SUM(discount_price),SUM(gst_amount)")
    if params[:q].present?
      @products_list = params[:product_id] if params[:product_id].present?
      @created_at_gteq = params[:q][:created_at_gteq] if params[:q][:created_at_gteq].present?
      @created_at_lteq = params[:q][:created_at_lteq] if params[:q][:created_at_lteq].present?
      params[:q][:created_at_lteq] = params[:q][:created_at_lteq].to_date.end_of_day if params[:q][:created_at_lteq].present?
      @created_at_gteq = @created_at_gteq.to_datetime
      @created_at_lteq = @created_at_lteq.to_datetime
      @purchase_item = PurchaseSaleItem.includes(:product).where(transaction_type: "Sale", created_at: @created_at_gteq.to_date.beginning_of_day..@created_at_lteq.to_date.end_of_day).group("product_id").order('products.title asc').pluck("products.title,SUM(quantity),SUM(total_cost_price),SUM(total_sale_price),SUM(discount_price),SUM(gst_amount)")
      @purchase_discount = PurchaseSaleDetail.where(transaction_type: "Sale", created_at: @created_at_gteq.to_date.beginning_of_day..@created_at_lteq.to_date.end_of_day).sum(:discount_price)
      @total_all = PurchaseSaleItem.includes(:product).where(transaction_type: "Sale", created_at: @created_at_gteq.to_date.beginning_of_day..@created_at_lteq.to_date.end_of_day).pluck("SUM(quantity),SUM(total_cost_price),SUM(total_sale_price),SUM(discount_price),SUM(gst_amount)")
      @purchase_item = PurchaseSaleItem.includes(:product).where(transaction_type: "Sale", created_at: @created_at_gteq.to_date.beginning_of_day..@created_at_lteq.to_date.end_of_day, product_id: @products_list).group("product_id").order('products.title asc').pluck("products.title,SUM(quantity),SUM(total_cost_price),SUM(total_sale_price),SUM(discount_price),SUM(gst_amount)") if params[:product_id].present?
      @purchase_discount = PurchaseSaleDetail.joins(:purchase_sale_items).where(transaction_type: "Sale", created_at: @created_at_gteq.to_date.beginning_of_day..@created_at_lteq.to_date.end_of_day, 'purchase_sale_items.product_id': @products_list).sum(:discount_price) if params[:product_id].present?
      @total_all = PurchaseSaleItem.includes(:product).where(transaction_type: "Sale", created_at: @created_at_gteq.to_date.beginning_of_day..@created_at_lteq.to_date.end_of_day, 'purchase_sale_items.product_id': @products_list).pluck("SUM(quantity),SUM(total_cost_price),SUM(total_sale_price),SUM(discount_price),SUM(gst_amount)") if params[:product_id].present?
    end
    @q = City.ransack(params[:q])
    @cities = @q.result
    @salary   = Salary.where(created_at: @created_at_gteq.to_date.beginning_of_day..@created_at_lteq.to_date.end_of_day).sum(:paid_salary)
    @advance = Salary.where(created_at: @created_at_gteq.to_date.beginning_of_day..@created_at_lteq.to_date.end_of_day).sum(:advance)
    @expense  = ExpenseEntry.where(created_at: @created_at_gteq.to_date.beginning_of_day..@created_at_lteq.to_date.end_of_day).sum(:amount)
    @investment  = Investment.where(created_at: @created_at_gteq.to_date.beginning_of_day..@created_at_lteq.to_date.end_of_day).sum(:debit)

    if params[:submit_pdf_staff_with].present?
      if @q.result.count > 0
        @q.sorts = 'created_at desc' if @q.sorts.empty?
      end
      @reports_pdf=@q.result
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
          footer:  {             # optional, use 'pdf_plain' for a pdf_plain.html.pdf.erb file, defaults to main layout
            right: '[page] of [topage]'},
          encoding: "UTF-8",
          show_as_html: false
        end
      end
    end
  end
  def sale_report
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

    @created_at_gteq = DateTime.now-30
    @created_at_lteq = DateTime.now
    if params[:q].present?
      @created_at_gteq = params[:q][:created_at_gteq] if params[:q][:created_at_gteq].present?
      @created_at_lteq = params[:q][:created_at_lteq] if params[:q][:created_at_lteq].present?
      @created_at_gteq = @created_at_gteq.to_datetime
      @created_at_lteq = @created_at_lteq.to_datetime
    end
    @q = City.ransack(params[:q])
    @cities = @q.result
    @reports = @q.result.page(params[:page]).per(100)

    @sale = PurchaseSaleDetail.where(transaction_type: "Sale",created_at: @created_at_gteq.to_date.beginning_of_day..@created_at_lteq.to_date.end_of_day ).group("DATE(created_at)").sum(:total_bill)
    @sale_discount = PurchaseSaleDetail.where(transaction_type: "Sale",created_at: @created_at_gteq.to_date.beginning_of_day..@created_at_lteq.to_date.end_of_day ).group("DATE(created_at)").sum(:discount_price)
    @purchase = PurchaseSaleDetail.where(transaction_type: "Purchase",created_at: @created_at_gteq.to_date.beginning_of_day..@created_at_lteq.to_date.end_of_day).group("DATE(created_at)").sum(:total_bill)
    @purchase_discount = PurchaseSaleDetail.where(transaction_type: "Purchase",created_at: @created_at_gteq.to_date.beginning_of_day..@created_at_lteq.to_date.end_of_day).group("DATE(created_at)").sum(:discount_price)
    @salary = Salary.where(created_at: @created_at_gteq.to_date.beginning_of_day..@created_at_lteq.to_date.end_of_day).group("DATE(created_at)").sum(:paid_salary)
    @advance = Salary.where(created_at: @created_at_gteq.to_date.beginning_of_day..@created_at_lteq.to_date.end_of_day).group("DATE(created_at)").sum(:advance)
    @expense = ExpenseEntry.where(created_at: @created_at_gteq.to_date.beginning_of_day..@created_at_lteq.to_date.end_of_day).group("DATE(created_at)").sum(:amount)
    @investment = Investment.where(created_at: @created_at_gteq.to_date.beginning_of_day..@created_at_lteq.to_date.end_of_day).group("DATE(created_at)").sum(:debit)

    @sale_total = PurchaseSaleDetail.where(transaction_type: "Sale",created_at: @created_at_gteq.to_date.beginning_of_day..@created_at_lteq.to_date.end_of_day ).sum(:total_bill)
    @sale_discount_total = PurchaseSaleDetail.where(transaction_type: "Sale",created_at: @created_at_gteq.to_date.beginning_of_day..@created_at_lteq.to_date.end_of_day ).sum(:discount_price)
    @purchase_total = PurchaseSaleDetail.where(transaction_type: "Purchase",created_at: @created_at_gteq.to_date.beginning_of_day..@created_at_lteq.to_date.end_of_day).sum(:total_bill)
    @purchase_discount_total = PurchaseSaleDetail.where(transaction_type: "Purchase",created_at: @created_at_gteq.to_date.beginning_of_day..@created_at_lteq.to_date.end_of_day).sum(:discount_price)
    @salary_total   = Salary.where(created_at: @created_at_gteq.to_date.beginning_of_day..@created_at_lteq.to_date.end_of_day).sum(:paid_salary)
    @advance_total = Salary.where(created_at: @created_at_gteq.to_date.beginning_of_day..@created_at_lteq.to_date.end_of_day).sum(:advance)
    @expense_total  = ExpenseEntry.where(created_at: @created_at_gteq.to_date.beginning_of_day..@created_at_lteq.to_date.end_of_day).sum(:amount)
    @investment_total  = Investment.where(created_at: @created_at_gteq.to_date.beginning_of_day..@created_at_lteq.to_date.end_of_day).sum(:debit)
    if params[:submit_pdf].present?
      if @q.result.count > 0
        @q.sorts = 'created_at desc' if @q.sorts.empty?
      end
      @reports_pdf=@q.result
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
          footer:  {             # optional, use 'pdf_plain' for a pdf_plain.html.pdf.erb file, defaults to main layout
            right: '[page] of [topage]'},
          encoding: "UTF-8",
          show_as_html: true
        end
      end
    end

  end


  def sale_report_analytics
    type = params[:type]
    case type
    when 'daily'
      date_limit = DateTime.current.all_day
    when 'weekly'
      date_limit = DateTime.current.all_week
    when 'monthly'
      date_limit = DateTime.current.all_month
    when 'yearly'
      date_limit = DateTime.current.all_year
    else
      date_limit = DateTime.current.all_day
    end

    @sale_total = PurchaseSaleDetail.where(transaction_type: "Sale",created_at: date_limit ).sum(:total_bill)
    @sale_discount_total = PurchaseSaleDetail.where(transaction_type: "Sale",created_at: date_limit ).sum(:discount_price)
    @purchase_total = PurchaseSaleDetail.where(transaction_type: "Purchase",created_at: date_limit).sum(:total_bill)
    @purchase_discount_total = PurchaseSaleDetail.where(transaction_type: "Purchase",created_at: date_limit).sum(:discount_price)
    @investment_total  = Investment.where(created_at: date_limit).sum(:debit)

    @salary_total   = Salary.where(created_at: date_limit).sum(:paid_salary)
    @advance_total = Salary.where(created_at: date_limit).sum(:advance)
    @expense_total  = ExpenseEntry.where(created_at: date_limit).sum(:amount)
    @total_profit = (@sale_total.to_f-@sale_discount_total.to_f)-
                   ((@purchase_total.to_f- @purchase_discount_total.to_f)+(@investment_total.to_f)+
                     (@salary_total.to_f+@advance_total.to_f)+(@expense_total.to_f))

    @values_arr = [@investment_total.to_f, @purchase_total.to_f- @purchase_discount_total.to_f,
                   @expense_total.to_f, @sale_total.to_f-@sale_discount_total.to_f, @total_profit
                   ]
    @keys_arr = ['Investments', 'Purchase', 'Expense', 'Sale', 'Total-Profit']
    respond_to do |format|
      format.js
    end
  end

  def sale_report_0
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

    @total_quantity=0
    @total_cost_price=0
    @total_sale_price=0
    @total_discount=0
    @total_total=0
    @total_profit_without_envesment=0
    @total_profit=0
    @total_expense=0
    @sale_report=Hash.new
    (1..@lastday).each do |i|

      @q = PurchaseSaleItem.where("extract(day from created_at)=? AND extract(month from created_at)=? AND extract(year from created_at)=?",i,@paid_to_month,@paid_to_year).where(transaction_type: "Sale").ransack()
      @expense = Expense.where("extract(day from expenses.created_at)=? AND extract(month from expenses.created_at)=? AND extract(year from expenses.created_at) = ?",i, @paid_to_month, @paid_to_year).sum(:expense)
      items=@q.result
      items.each do |item|
        if item.product_id.present?
          quantity=item.quantity.present? ? item.quantity : 0
          product_cost=Product.find(item.product_id).cost.present? ?  Product.find(item.product_id).cost : 0
          cost_price=product_cost*quantity
          sale_price=item.total_sale_price.present? ? item.total_sale_price : 0
          discount=item.discount_price.present? ? item.discount_price : 0
          total=sale_price-discount
          profit=total-cost_price
          size_1=item.size_1.to_i
          size_2=item.size_2.to_i
          size_3=item.size_3.to_i
          size_4=item.size_4.to_i
          size_5=item.size_5.to_i
          size_6=item.size_6.to_i
          size_7=item.size_7.to_i
          size_8=item.size_8.to_i
          size_9=item.size_9.to_i
          size_10=item.size_10.to_i
          size_11=item.size_11.to_i
          size_12=item.size_12.to_i
          size_13=item.size_13.to_i
          @quantity+=quantity
          @cost_price+=cost_price
          @sale_price+=sale_price
          @discount+=discount
          @total+=total
          @profit+=profit
          @size_1+=size_1
          @size_2+=size_2
          @size_3+=size_3
          @size_4+=size_4
          @size_5+=size_5
          @size_6+=size_6
          @size_7+=size_7
          @size_8+=size_8
          @size_9+=size_9
          @size_10+=size_10
          @size_11+=size_11
          @size_12+=size_12
          @size_13+=size_13
        end
      end
      @total = @total-@expense
      @profit = @total-@cost_price
      @sale_report[i] = @quantity.round(2),@cost_price.round(2),@sale_price.round(2),@discount.round(2),@total.round(2),@profit.round(2),@expense,@size_1,@size_2,@size_3,@size_4,@size_5,@size_6,@size_7,@size_8,@size_9,@size_10,@size_11,@size_12,@size_13
      @total_quantity+=@quantity
      @total_cost_price+=@cost_price
      @total_sale_price+=@sale_price
      @total_discount+=@discount
      @total_total+=@total
      @total_profit_without_envesment+=@profit
      @total_profit+=@profit
      @total_expense+=@expense

    end
  end


  def stock_report
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

    @stock_report_day=Hash.new
    @total_stock_day=0
    @sale_stock_day=0
    @final_stock_day=0
    @remaning_stock_day=0
    @purchase_stock_day=0
    @q=Product.ransack()
    @q.result
    (1..@lastday).each do |i|
      sale=PurchaseSaleItem.where("extract(day from created_at)=? AND extract(month from created_at)=? AND extract(year from created_at)=?",i,@paid_to_month,@paid_to_year).where(transaction_type: "Sale").sum(:total_sale_price)
      purchase=PurchaseSaleItem.where("extract(day from created_at)=? AND extract(month from created_at)=? AND extract(year from created_at)=?",i,@paid_to_month,@paid_to_year).where(transaction_type: "Purchase").sum(:total_cost_price)
      stock=purchase-sale
      @total_stock_day+=stock
      @sale_stock_day+=sale
      @purchase_stock_day+=purchase
      @remaning_stock_day+=stock
      @final_stock_day+=@total_stock_day
      @stock_report_day[i] = purchase,sale,stock,@total_stock_day
    end
    @sale_stock=0
    @total_stock=0
    @final_stock=0
    @remaning_stock=0
    @purchase_stock=0
    @stock_report=Hash.new
    (1..12).each do |i|
      @paid_to_month == 0 ? @paid_to_month = 12 : @paid_to_month
      sale=PurchaseSaleItem.where("extract(month from created_at)=? AND extract(year from created_at)=?",@paid_to_month,@paid_to_year).where(transaction_type: "Sale").sum(:total_sale_price)
      purchase=PurchaseSaleItem.where("extract(month from created_at)=? AND extract(year from created_at)=?",@paid_to_month,@paid_to_year).where(transaction_type: "Purchase").sum(:total_cost_price)
      stock=purchase-sale
      @total_stock+=stock
      @sale_stock+=sale
      @purchase_stock+=purchase
      @remaning_stock+=stock
      @final_stock+=@total_stock
      @stock_report[[Date::ABBR_MONTHNAMES[@paid_to_month],@paid_to_year]] = purchase,sale,stock,@total_stock
      @paid_to_month = @paid_to_month - 1
      @paid_to_month == 0 ? @paid_to_year = @paid_to_year-1 : @paid_to_year
    end

  end

  private

    def activated_list(model_name)
      @q = model_name.constantize.where(terminated: false, deleted: false).ransack(params[:q])
      @q.result
    end

    def deleted_list(model_name)
      @q = model_name.constantize.where(deleted: true).ransack(params[:q])
      @q.result
    end

    def terminated_list(model_name)
      @q = model_name.constantize.where(terminated: true).ransack(params[:q])
      @q.result
    end
end

def chart_of_account_analytics

  @user_group_count = SysUser.where('balance > 0').group('user_group').count
  @u_group_keys = @user_group_count.keys&.compact&.map { |a| a.gsub(' ', '-') }
  @u_group_count = @user_group_count.values

  @user_group_balance = SysUser.where('balance > 0').group('user_group').sum(:balance)
  @u_balance_keys = @user_group_balance.keys&.compact&.map { |a| a.gsub(' ', '-') }
  @u_balance_count = @user_group_balance.values

  @staff_dep_count = Staff.joins(:department).where('balance > 0').group('departments.title').count
  @dep_keys = @staff_dep_count.keys&.compact&.map { |a| a.gsub(' ', '-') }
  @dep_values = @staff_dep_count.values

  @staff_dep_balance = Staff.joins(:department).where('balance > 0').group('departments.title').sum(:balance)
  @staff_dep_sorted = @staff_dep_balance&.map { |a| [a.first, a.last.to_f] }.to_h
  @staff_balance_keys = @staff_dep_sorted.keys&.compact&.map { |a| a.gsub(' ', '-') }
  @staff_balance_values = @staff_dep_sorted.values

end
