class ApplicationRecord < ActiveRecord::Base
  self.abstract_class = true
  include CsvMethods

  def self.set_connection
    if RequestStore.store[:company_type].present?
      Rails.cache.clear
      establish_connection "#{Rails.env}_#{RequestStore.store[:company_type]}".to_sym
    else
      establish_connection "#{Rails.env}".to_sym
    end
  end

  def self.chart_of_account_pdf(file_name, file_type, typeingly, logs)
    if typeingly == 'daily'
      @search_of = 1.day.ago.all_day
    elsif typeingly == 'weekly'
      @search_of = 1.day.ago.all_week
    else
      @search_of = 1.day.ago.all_month
    end

    case file_type
    when 'chart-of-account'
      set_variables_chart_of_accounts
      @pdf_file_path = 'reports/chart_of_account_report.pdf.erb'
    when 'sysuser-ledger-book'
      set_variables_sys_user_ledger_book
      check_for_logs_or_reports(logs, 'ledgerbook', nil, 'ledger_books/sys_user_ledger_logs.pdf.erb',
                                'ledger_books/sys_user_ledger_report.pdf.erb')
    when 'staff-ledger-book'
      set_variables_staff_ledger_book
      check_for_logs_or_reports(logs, 'StaffLedgerBook', nil, 'staff_ledger_books/staff_ledger_book_logs.pdf.erb',
                                'staff_ledger_books/staff_ledger_book_report.pdf.erb')
    when 'sale'
      set_variables_sale('Sale')
      check_for_logs_or_reports(logs, 'PurchaseSaleDetail', 'Sale', 'purchase_sale_details/sale_details_logs.pdf.erb',
                                'purchase_sale_details/sale_details_report.pdf.erb')
    when 'purchase'
      set_variables_sale('Purchase')
      check_for_logs_or_reports(logs, 'PurchaseSaleDetail', 'Purchase', 'purchase_sale_details/sale_details_logs.pdf.erb',
                                'purchase_sale_details/sale_details_report.pdf.erb')
    when 'payment'
      set_variables_payment
      check_for_logs_or_reports(logs, 'Payment', nil, 'payments/payment_logs.pdf.erb',
                                'payments/payment_report.pdf.erb')
    when 'expense'
      set_variables_expense
      check_for_logs_or_reports(logs, 'ExpenseEntry', nil, 'expenses/expense_logs.pdf.erb',
                                'expenses/expense_report.pdf.erb')
    when 'investment'
      set_variables_investment
      check_for_logs_or_reports(logs, 'Investment', nil, 'investments/investment_logs.pdf.erb',
                                'investments/investment_report.pdf.erb')
    end
    pdf = WickedPdf.new.pdf_from_string(ApplicationController.new.render_to_string(
                                          template: @pdf_file_path,
                                          locals: @local_vars_hash,
                                          margin: {
                                            margin_top: @pos_setting&.pdf_margin_top.to_f,
                                            margin_right: @pos_setting&.pdf_margin_right.to_f,
                                            margin_bottom: @pos_setting&.pdf_margin_bottom.to_f,
                                            margin_left: @pos_setting&.pdf_margin_left.to_f
                                          },
                                          layout: 'task_reports_pdf.html',
                                          footer: {
                                            right: '[page] of [topage]'
                                          }))
    date_for_folder = Date.yesterday.to_s.gsub('-', '')
    if logs.present?
      Dir.mkdir(Rails.root.join("../../shared/version_reports/#{typeingly}/#{date_for_folder}")) unless File.exist?(Rails.root.join("../../shared/version_reports/#{typeingly}/#{date_for_folder}"))
      Dir.mkdir(Rails.root.join("../../shared/version_reports/#{typeingly}/#{date_for_folder}/#{file_name}")) unless File.exist?(Rails.root.join("../../shared/version_reports/#{typeingly}/#{date_for_folder}/#{file_name}"))
      pdf_name = "#{file_type}-logs.pdf"
      pdf_path = Rails.root.join("../../shared/version_reports/#{typeingly}/#{date_for_folder}/#{file_name}", pdf_name)
    else
      Dir.mkdir(Rails.root.join("../../shared/reports/#{typeingly}/#{date_for_folder}")) unless File.exist?(Rails.root.join("../../shared/reports/#{typeingly}/#{date_for_folder}"))
      Dir.mkdir(Rails.root.join("../../shared/reports/#{typeingly}/#{date_for_folder}/#{file_name}")) unless File.exist?(Rails.root.join("../../shared/reports/#{typeingly}/#{date_for_folder}/#{file_name}"))
      pdf_name = "#{file_type}-report.pdf"
      pdf_path = Rails.root.join("../../shared/reports/#{typeingly}/#{date_for_folder}/#{file_name}", pdf_name)
    end
    File.open(pdf_path, 'wb') do |file|
      file.binmode
      file << pdf.force_encoding('UTF-8')
    end
  end

  def self.check_for_logs_or_reports(logs, item_type, sale_purchase, logs_pdf_path, report_pdf_path)
    if logs.present?
      set_variables_of_logs(item_type, sale_purchase)
      @pdf_file_path = logs_pdf_path
    else
      @pdf_file_path = report_pdf_path
    end
  end

  def self.set_variables_chart_of_accounts
    @pos_setting = PosSetting.first
    @sys_user_payable = SysUser.where('balance > 0').order(:user_group)
    @sys_user_receiveable = SysUser.where('balance < 0').order(:user_group)
    @all_user = SysUser.all
    @user_types = UserType.all
    @staff_names = Staff.all
    @sys_user_payable_group = SysUser.where('balance > 0').group(:user_group).sum(:balance)
    @sys_user_receiveable_group = SysUser.where('balance < 0').group(:user_group).sum(:balance)
    @departments = Department.all
    @staff_reciveable = Staff.where('balance<0').where(deleted: false).sort_by{ |s| s.department_id.to_i }
    @staff_payable = Staff.where('balance>0').where(deleted: false).sort_by{ |s| s.department_id.to_i }
    @staff_payable_group = Staff.joins(:department).where('balance>0').where(deleted: false).group('departments.title').sum(:balance)
    @credit_salary_list = SalaryDetail.joins(:staff).where('amount>0').where(purchase_sale_detail_id:nil,daily_book_id: nil).where.not(id: Payment.where(paymentable_type:"SalaryDetail").pluck(:paymentable_id)).group('staffs.name').sum(:amount)
    @credit_salary = SalaryDetail.joins(:staff).where('amount>0').where(purchase_sale_detail_id:nil,daily_book_id: nil).where.not(id: Payment.where(paymentable_type:"SalaryDetail").pluck(:paymentable_id)).sum(:amount).to_f
    @sale_product_list = PurchaseSaleItem.joins(:product).where(transaction_type: 'Sale').group('products.title').having('sum(total_sale_price)>0').sum(:total_sale_price)
    @investments_debit = Investment.sum(:debit)
    @investments_credit = Investment.sum(:credit)
    @expense_total = ExpenseEntry.joins(:expense_type).sum(:amount)
    @expense_list = ExpenseEntry.joins(:expense_type).group('expense_types.title').having('sum(amount)>0').sum(:amount)

    if @pos_setting.present?
      if @pos_setting.sys_type == 'batha' or @pos_setting.sys_type == 'Factory'
        @pos_type_batha = true
      else
        @pos_type_batha = false
      end
    else
      @pos_type_batha = false
    end
    if @pos_type_batha.present?
      @salary_detail_list = SalaryDetail.joins(staff: :department).where(comment:["Payment Credit", nil]).where.not('departments.id>=4').group('departments.title').sum(:amount)
      @salary_detail_kharkar = SalaryDetail.joins(staff: :department).where(comment:["Payment Credit",nil]).where('khakar_credit>0').where.not('departments.id=4').sum(:khakar_credit)
      @salary_detail_total = SalaryDetail.joins(staff: :department).where(comment:["Payment Credit",nil]).where.not('departments.id>=4').sum(:amount)+SalaryDetail.joins(staff: :department).where(comment:["Payment Credit",nil]).where('khakar_credit>0').where.not('departments.id=4').sum(:khakar_credit)
      @khakar_salary_detail_list = SalaryDetail.joins(staff: :department).where(comment:["Payment Credit",nil]).where('khakar_credit>0').where.not('departments.id=4').group('departments.title').sum(:khakar_credit)
    else
      @salary_detail_list = SalaryDetail.joins(staff: :department).where(comment:["Payment Credit",nil]).where.not('departments.id=4').group('departments.title').sum(:amount)
      @salary_detail_kharkar = SalaryDetail.joins(staff: :department).where(comment:["Payment Credit",nil]).where('khakar_credit>0').where.not('departments.id=4').sum(:khakar_credit)
      @salary_detail_total = SalaryDetail.joins(staff: :department).where(comment:["Payment Credit",nil]).where.not('departments.id=4').sum(:amount)+SalaryDetail.joins(staff: :department).where(comment:["Payment Credit",nil]).where('khakar_credit>0').where.not('departments.id=4').sum(:khakar_credit)
      @khakar_salary_detail_list = SalaryDetail.joins(staff: :department).where(comment:["Payment Credit",nil]).where('khakar_credit>0').where.not('departments.id=4').group('departments.title').sum(:khakar_credit)
    end

    @purchase_sale_detail_discount_list = PurchaseSaleDetail.where(transaction_type:'Sale').where.not(discount_price:[nil,0])
    @purchase_item_list = PurchaseSaleItem.joins(:item).where(transaction_type:'Purchase').group('items.title').having('sum(total_cost_price)>0').sum(:total_cost_price)
    @purchase_item_total = PurchaseSaleItem.joins(:item).where(transaction_type:'Purchase').sum(:total_cost_price)
    @purchase_product_list = PurchaseSaleItem.joins(:product).where(transaction_type:'Purchase').group('products.title').having('sum(total_cost_price)>0').sum(:total_cost_price)
    @purchase_product_total = PurchaseSaleItem.joins(:product).where(transaction_type:'Purchase').sum(:total_cost_price)

    @sale_item_list = PurchaseSaleItem.joins(:item).where(transaction_type:'Sale').group('items.title').having('sum(total_sale_price)>0').sum(:total_sale_price)
    @sale_item_total = PurchaseSaleItem.joins(:item).where(transaction_type:'Sale').sum(:total_sale_price)
    @sale_product_total = PurchaseSaleItem.joins(:product).where(transaction_type:'Sale').sum(:total_sale_price)
    @accounts = Account.all

    @local_vars_hash = {
      pos_setting: @pos_setting,
      sys_user_payable: @sys_user_payable,
      sys_user_receiveable: @sys_user_receiveable,
      all_user: @all_user,
      user_types: @user_types,
      staff_names: @staff_names,
      sys_user_payable_group: @sys_user_payable_group,
      sys_user_receiveable_group: @sys_user_receiveable_group,
      departments: @departments,
      staff_reciveable: @staff_reciveable,
      staff_payable: @staff_payable,
      staff_payable_group: @staff_payable_group,
      credit_salary_list: @credit_salary_list,
      credit_salary: @credit_salary,
      sale_product_list: @sale_product_list,
      investments_debit: @investments_debit,
      investments_credit: @investments_credit,
      expense_total: @expense_total,
      expense_list: @expense_list,
      purchase_sale_detail_discount_list: @purchase_sale_detail_discount_list,
      purchase_item_list: @purchase_item_list,
      purchase_item_total: @purchase_item_total,
      purchase_product_list: @purchase_product_list,
      purchase_product_total: @purchase_product_total,
      sale_item_list: @sale_item_list,
      sale_item_total: @sale_item_total,
      sale_product_total: @sale_product_total,
      accounts: @accounts,
      salary_detail_list: @salary_detail_list,
      salary_detail_kharkar: @salary_detail_kharkar,
      salary_detail_total: @salary_detail_total,
      khakar_salary_detail_list: @khakar_salary_detail_list
    }
  end

  def self.set_variables_of_logs(item_type, sale_purchase)
    if sale_purchase.present?
      @ledger_book_logs = PaperTrail::Version.where(item_id: PurchaseSaleDetail.where(transaction_type: sale_purchase), item_type:'PurchaseSaleDetail', created_at: @search_of).order('created_at desc')
    else
      @ledger_book_logs = PaperTrail::Version.where(item_type: item_type, created_at: @search_of).order('created_at desc')
    end
    @local_vars_hash = {
      logs_data: @ledger_book_logs,
      type: sale_purchase
    }
  end

  def self.set_variables_sys_user_ledger_book
    @ledger_books = LedgerBook.where(created_at: @search_of)
    @sys_user=SysUser.new(opening_balance: 0, created_at: DateTime.now)
    @ledger_books_pdf = LedgerBook.where(created_at: @search_of)
    @sys_users = SysUser.all
    @local_vars_hash = {
      ledger_books: @ledger_books,
      sys_user: @sys_user,
      ledger_books_pdf: @ledger_books_pdf,
      sys_users: @sys_users
    }
  end

  def self.set_variables_staff_ledger_book
    @staff_ledger_books_pdf = StaffLedgerBook.joins(:staff).where('credit>0 or debit>0 or credit<0 or debit<0')
                                             .where(created_at: @search_of).sort_by(&:created_at)
    @debit = @staff_ledger_books_pdf.pluck(:debit).compact.sum
    @credit = @staff_ledger_books_pdf.pluck(:credit).compact.sum
    @quantity = StaffLedgerBook.joins(:staff, :salary_detail)
                               .sum(:quantity) + StaffLedgerBook.joins(:staff, :salary_detail).sum(:khakar_remaning)
    @local_vars_hash = {
      staff_ledger_books_pdf: @staff_ledger_books_pdf,
      debit: @debit,
      credit: @credit,
      quantity: @quantity
    }
  end

  def self.set_variables_sale(type)
    @sys_users = SysUser.all
    @products = Product.all
    @staffs = Staff.all
    if type.eql? 'Sale'
      @products_sale_price = PurchaseSaleDetail.joins(purchase_sale_items: :product)
                                               .where(transaction_type: type)
                                               .where('purchase_sale_items.product_id': @products)
                                               .where(sys_user_id: @sys_users,
                                                      'purchase_sale_items.created_at': @search_of,
                                                      transaction_type: type)
                                               .group(:title).average('purchase_sale_items.sale_price')
      @products_sale = PurchaseSaleDetail.joins(purchase_sale_items: :product).where(transaction_type: type)
                                         .where('purchase_sale_items.product_id': @products)
                                         .where(sys_user_id: @sys_users, 'purchase_sale_items.created_at': @search_of,transaction_type: type)
                                         .group(:title).sum(:total_sale_price)
      @products_count = PurchaseSaleDetail.joins(purchase_sale_items: :product).where(transaction_type: type).where('purchase_sale_items.product_id': @products).where(sys_user_id: @sys_users, 'purchase_sale_items.created_at': @search_of,transaction_type: type).group(:title).sum('purchase_sale_items.quantity')
      @products_sale_total = PurchaseSaleDetail.joins(purchase_sale_items: :product).where(transaction_type: type).where('purchase_sale_items.product_id': @products).where(sys_user_id: @sys_users, 'purchase_sale_items.created_at': @search_of,transaction_type: type).sum(:total_sale_price)
      @product_carriage = PurchaseSaleDetail.where(sys_user_id: @sys_users, created_at: @search_of, transaction_type: type, staff_id: @staffs).sum(:carriage)
      @product_loading = PurchaseSaleDetail.where(sys_user_id: @sys_users, created_at: @search_of, transaction_type: type, staff_id: @staffs).sum(:loading)
    else
      @products_sale_price = PurchaseSaleDetail.joins(purchase_sale_items: :product)
                                               .where(transaction_type: type)
                                               .where('purchase_sale_items.product_id': @products)
                                               .where(sys_user_id: @sys_users,
                                                      'purchase_sale_items.created_at': @search_of,
                                                      transaction_type: type)
                                               .group(:title).average(:cost_price)
      @products_sale = PurchaseSaleDetail.joins(purchase_sale_items: :product).where(transaction_type: type)
                                         .where('purchase_sale_items.product_id': @products)
                                         .where(sys_user_id: @sys_users, 'purchase_sale_items.created_at': @search_of,transaction_type: type)
                                         .group(:title).sum(:total_cost_price)
      @products_count = PurchaseSaleDetail.joins(purchase_sale_items: :product).where(transaction_type: type).where('purchase_sale_items.product_id': @products).where(sys_user_id: @sys_users, 'purchase_sale_items.created_at': @search_of,transaction_type: type).group(:title).sum('purchase_sale_items.quantity')
      @products_sale_total = PurchaseSaleDetail.joins(purchase_sale_items: :product).where(transaction_type: type).where('purchase_sale_items.product_id': @products).where(sys_user_id: @sys_users, 'purchase_sale_items.created_at': @search_of,transaction_type: type).sum(:total_cost_price)
      @product_carriage = PurchaseSaleDetail.where(sys_user_id: @sys_users, created_at: @search_of, transaction_type: type, staff_id: @staffs).sum(:carriage)
      @product_loading = PurchaseSaleDetail.where(sys_user_id: @sys_users, created_at: @search_of, transaction_type: type, staff_id: @staffs).sum(:loading)
    end
    @local_vars_hash = {
      products_sale_price: @products_sale_price,
      products_sale: @products_sale,
      products_count: @products_count,
      products_sale_total: @products_sale_total,
      product_carriage: @product_carriage,
      product_loading: @product_loading,
      type: type
    }
  end

  def self.set_variables_payment
    @payments = Payment.where(created_at: @search_of)
    @local_vars_hash = {
      payments: @payments
    }
  end

  def self.set_variables_expense
    @expenses = Expense.order('id desc').where(created_at: @search_of)
    @expense_payment_total = Expense.joins(expense_entries: :payment).where('expenses.id': @expenses.pluck(:id), 'expenses.created_at': @search_of).sum(:debit)
    @local_vars_hash = {
      expenses: @expenses,
      expense_payment_total: @expense_payment_total
    }
  end

  def self.set_variables_investment
    @investments = Investment.where(created_at: @search_of)
    @local_vars_hash = {
      investments: @investments
    }
  end

  # include PublicActivity::Model
  # tracked owner: Proc.new{ |controller, model| controller.current_user },
  #         parameters: :previous_changes
end
