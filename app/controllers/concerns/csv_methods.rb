# frozen_string_literal: true

# CSV Methods
module CsvMethods
  extend ActiveSupport::Concern
  def trail_balance_csv
    @date = Date.today
    @time = Time.zone.now
    values = []
    CSV.generate do |csv|
      csv.add_row [
        'Printing Date Time ', "#{@time.strftime('%d')} #{@time.strftime('%b')} #{@time.strftime('%y')}",
        @time.strftime('%I:%M%p')
      ]
      csv.add_row ['Report by', current_user.name]
      csv.add_row ['------------', '------------']
      csv.add_row ['Trail Balance Report']
      csv.add_row ['------------']
      csv.add_row ['Users']
      csv.add_row ['------------']
      csv.add_row ['Users Payable']
      csv.add_row ['Code', 'Name', 'User Group', 'Status', 'Debit', 'Credit', 'Balance', 'Check']
      @sys_user_payable.each do |sys_user|
        debit_sum  = @sys_user_payable_ledger_book_debit[sys_user.id].to_d
        credit_sum = @sys_user_payable_ledger_book_credit[sys_user.id].to_d
        balance = sys_user.balance
        values = [sys_user.code, sys_user.name, sys_user.user_group, sys_user.status, debit_sum, credit_sum, balance]
        credit_debit = credit_sum - debit_sum
        if balance == credit_debit
          values.push('')
        else
          values.push(balance - credit_debit)
        end
        csv.add_row values
      end
      csv.add_row [
        'Total', '', '', '', @sys_user_payable_ledger_book_debit_total, @sys_user_payable_ledger_book_credit_total,
        @sys_user_payable.pluck('balance').map(&:abs).sum
      ]
      csv.add_row [
        '------------', '------------', '------------', '------------', '------------', '------------',
        '------------', '------------'
      ]
      csv.add_row ['Users Reciveable']
      csv.add_row ['Code', 'Name', 'User Group', 'Status', 'Debit', 'Credit', 'Balance', 'Check']
      @sys_user_receiveable.each do |sys_user|
        debit_sum  = @sys_user_receiveable_ledger_book_debit[sys_user.id].to_d
        credit_sum = @sys_user_receiveable_ledger_book_credit[sys_user.id].to_d
        balance = sys_user.balance
        values = [sys_user.code, sys_user.name, sys_user.user_group, sys_user.status, debit_sum, credit_sum, balance]
        credit_debit = credit_sum - debit_sum
        if balance == credit_debit
          values.push('')
        else
          values.push(balance - credit_debit)
        end
        csv.add_row values
      end
      csv.add_row [
        'Total', '', '', '', @sys_user_receiveable_ledger_book_debit_total,
        @sys_user_receiveable_ledger_book_credit_total, @sys_user_receiveable.pluck('balance').map(&:abs).sum
      ]
      csv.add_row [
        '------------', '------------', '------------', '------------', '------------', '------------',
        '------------', '------------'
      ]
      csv.add_row ['Users Nill']
      csv.add_row ['Code', 'Name', 'User Group', 'Status', 'Debit', 'Credit', 'Balance', 'Check']
      @sys_user_nill.each do |sys_user|
        debit_sum  = @sys_user_nill_ledger_book_debit[sys_user.id].to_d
        credit_sum = @sys_user_nill_ledger_book_credit[sys_user.id].to_d
        balance = sys_user.balance
        values = [sys_user.code, sys_user.name, sys_user.user_group, sys_user.status, debit_sum, credit_sum, balance]
        credit_debit = credit_sum - debit_sum
        balance.eql?(credit_debit) ? values.push('') : values.push(balance - credit_debit)
        csv.add_row values
      end
      csv.add_row [
        'Total', '', '', '', @sys_user_nill_ledger_book_debit_total,
        @sys_user_nill_ledger_book_credit_total, @sys_user_nill.pluck('balance').map(&:abs).sum
      ]
      csv.add_row [
        '------------', '------------', '------------', '------------', '------------', '------------',
        '------------', '------------'
      ]
      csv.add_row ['Staff']
      csv.add_row ['------------']
      csv.add_row ['Staff Payable']
      csv.add_row ['Status', 'Code', 'Name', 'Monthly/Wage', 'Department/Raw', 'Debit', 'Credit', 'Balance', 'Check']
      @staff_payable.each do |staff|
        department = staff.department.present? ? staff.department.title : ''
        raw = staff.staff_raw_products.present? ? staff.staff_raw_products_titles : ''
        debit_sum  = @staff_payable_ledger_book_debit[staff.id].to_d
        credit_sum = @staff_payable_ledger_book_credit[staff.id].to_d
        balance = staff.balance.to_f.round(2)
        values = [
          staff.staff_type, staff.code, staff.full_name, staff.staff_salary_or_wage.to_f.round(2),
          "#{department} : #{raw}", debit_sum, credit_sum, balance
        ]
        credit_debit = credit_sum - debit_sum
        balance.eql?(credit_debit) ? values.push('') : values.push(balance - credit_debit)
        csv.add_row values
      end
      csv.add_row [
        'Total', '', '', '', '', '', '', @staff_payable.sum('balance')
      ]
      csv.add_row [
        '------------', '------------', '------------', '------------', '------------', '------------',
        '------------', '------------', '------------'
      ]
      csv.add_row ['Staff Reciveable']
      csv.add_row ['Status', 'Code', 'Name', 'Monthly/Wage', 'Department/Raw', 'Debit', 'Credit', 'Balance', 'Check']
      @staff_reciveable.each do |staff|
        department = staff.department.present? ? staff.department.title : ''
        raw = staff.staff_raw_products.present? ? staff.staff_raw_products_titles : ''
        debit_sum  = @staff_reciveable_ledger_book_debit[staff.id].to_d
        credit_sum = @staff_reciveable_ledger_book_credit[staff.id].to_d
        balance = staff.balance.to_f.round(2)
        values = [
          staff.staff_type, staff.code, staff.full_name, staff.staff_salary_or_wage.to_f.round(2),
          "#{department} : #{raw}", debit_sum, credit_sum, balance
        ]
        credit_debit = credit_sum - debit_sum
        balance.eql?(credit_debit) ? values.push('') : values.push(balance - credit_debit)
        csv.add_row values
      end
      csv.add_row [
        'Total', '', '', '', '', '', '', @staff_reciveable.sum('balance')
      ]
      csv.add_row [
        '------------', '------------', '------------', '------------', '------------', '------------',
        '------------', '------------', '------------'
      ]
      csv.add_row ['Staff Nill']
      csv.add_row ['Status', 'Code', 'Name', 'Monthly/Wage', 'Department/Raw', 'Debit', 'Credit', 'Balance', 'Check']
      @staff_nill.each do |staff|
        department = staff.department.present? ? staff.department.title : ''
        raw = staff.staff_raw_products.present? ? staff.staff_raw_products_titles : ''
        debit_sum  = @staff_nill_ledger_book_debit[staff.id].to_d
        credit_sum = @staff_nill_ledger_book_credit[staff.id].to_d
        balance = staff.balance.to_f.round(2)
        values = [
          staff.staff_type, staff.code, staff.full_name, staff.staff_salary_or_wage.to_f.round(2),
          "#{department} : #{raw}", debit_sum, credit_sum, balance
        ]
        credit_debit = credit_sum - debit_sum
        balance.eql?(credit_debit) ? values.push('') : values.push(balance - credit_debit)
        csv.add_row values
      end
      csv.add_row [
        'Total', '', '', '', '', '', '', @staff_nill.sum('balance')
      ]
      csv.add_row [
        '------------', '------------', '------------', '------------', '------------', '------------'
      ]
      csv.add_row ['Accounts']
      csv.add_row ['Title', 'Bank Name', 'Debit', 'Credit', 'Balance', 'Check']
      @accounts.each do |account|
        debit_sum  = @account_debit[account.title].to_d
        credit_sum = @account_credit[account.title].to_d
        balance = account.amount.to_f.round(2)
        values = [account.title, account.bank_name, debit_sum, credit_sum, balance]
        credit_debit = credit_sum - debit_sum
        balance.eql?(credit_debit) ? values.push('') : values.push(balance - credit_debit)
        csv.add_row values
      end
      csv.add_row [
        'Total', '', @account_debit_total.to_f.round(2), @account_credit_total.to_f.round(2),
        @accounts.sum(:amount).abs.to_f.round(2)
      ]
      csv.add_row ['------------', '------------', '------------', '------------' ]
      csv.add_row ['Expenses Receivable']
      csv.add_row %w[Title Debit Credit Check]
      @expense_list.each do |exp|
        balance = exp.last.to_f.round(2)
        credit_expense = @credit_expense[exp&.first&.last].to_f.round(2)
        values = [exp&.first&.last, balance, credit_expense]
        balance.eql?(credit_expense) ? values.push('') : values.push(balance - credit_expense)
        csv.add_row values
      end
      csv.add_row ['Total', @expense_total.abs.to_f.round(2), @total_credit_expense.abs.to_f.round(2)]
      csv.add_row ['------------', '------------']
      csv.add_row ['Purchase Receivable']
      csv.add_row %w[Title Amount]
      @purchase_item_list.each { |exp| csv.add_row [exp.first, exp.last.to_f.round(2)] }
      @purchase_product_list.each { |exp| csv.add_row [exp.first, exp.last.to_f.round(2)] }
      csv.add_row ['Total', @purchase_item_total.to_i + @purchase_product_total.to_i]
      csv.add_row ['------------', '------------']
      csv.add_row ['Sale Payable']
      csv.add_row %w[Title Amount]
      @sale_item_list.each { |exp| csv.add_row [exp.first, exp.last.to_f.round(2)] }
      @sale_product_list.each { |exp| csv.add_row [exp.first, exp.last.to_f.round(2)] }
      csv.add_row ['Total', @sale_item_total.to_i + @sale_product_total.to_i]
      csv.add_row ['------------', '------------']
      csv.add_row ['Salary']
      csv.add_row %w[Title Amount]
      @salary_detail_list.each { |exp| csv.add_row [exp.first, exp.last.to_f.round(2)] }
      @khakar_salary_detail_list.each { |exp| csv.add_row [exp.first, exp.last.to_f.round(2)] }
      csv.add_row ['Total', @salary_detail_total.to_i]
    end
  end

  def chart_of_account_csv
    @date = Date.today
    @time = Time.zone.now
    CSV.generate do |csv|
      csv.add_row [
        'Printing Date Time ', "#{@time.strftime('%d')} #{@time.strftime('%b')} #{@time.strftime('%y')}",
        @time.strftime('%I:%M%p')
      ]
      csv.add_row ['Report by', current_user.name]
      csv.add_row []
      csv.add_row ['Chart of Account']
      csv.add_row []
      csv.add_row ['(Jama) Payable Details']
      csv.add_row ['(Jama) User List']
      csv.add_row %w[Code Name Group Balance]
      @last_group = @sys_user_payable.first.user_group if @sys_user_payable.present?
      @balance = 0
      @count = 0
      @sys_user_payable.each do |sys_user|
        if @last_group != sys_user.user_group
          csv.add_row ['', '', 'Total', convert_to_delimiter(@balance.round(2))]
          @last_group = sys_user.user_group
          @balance = 0
        end
        @count += 1
        csv.add_row [sys_user.code, sys_user.name, sys_user.user_group, convert_to_delimiter(sys_user.balance.abs)]
        @balance += sys_user.balance.round(2).abs
        if @sys_user_payable.last.code.eql?(sys_user.code)
          csv.add_row []
          csv.add_row ['', '', 'Total', convert_to_delimiter(@balance.round(2))]
          @balance = 0
        end
      end
      csv.add_row []
      csv.add_row ['Total', @count, '', convert_to_delimiter(@sys_user_payable.pluck('balance').map(&:abs).sum)]
      csv.add_row []
      csv.add_row ['(Jama) Staff/Labour List']
      csv.add_row %w[Code Name Department Balance]
      @last_department = @staff_payable.first.department if @staff_payable.present?
      @balance = 0
      @count = 0
      @staff_payable.each do |staff|
        if @last_department != staff.department
          csv.add_row ['', '', 'Total', convert_to_delimiter(@balance.round(2))]
          @last_department = staff.department
          @balance = 0
        end
        @count += 1
        dep = staff.department.present? ? staff.department.title : ''
        raw = staff.staff_raw_products.present? ? staff.staff_raw_products_titles : ''
        csv.add_row [staff.code, staff.full_name, "#{dep}:#{raw}", convert_to_delimiter(staff.balance.abs)]
        @balance += staff.balance.round(2).abs
        if @staff_payable.last.code == staff.code
          csv.add_row []
          csv.add_row ['Total', @staff_payable.count, '', convert_to_delimiter(@balance.round(2))]
          @balance = 0
        end
      end
      csv.add_row []
      csv.add_row ['Total', @count, '', convert_to_delimiter(@staff_payable.pluck('balance').map(&:abs).sum)]
      csv.add_row []
      csv.add_row ['(Jama) Sale List']
      csv.add_row %w[Title Amount Title Amount]
      @sale_product_list.each_slice(2) do |s|
        csv.add_row [s.first.first, s.first.last.to_f.round(2), s.last.first, s.last.last.to_f.round(2)]
      end
      @sale_item_list.each_slice(2) do |s|
        csv.add_row [s.first.first, s.first.last.to_f.round(2), s.last.first, s.last.last.to_f.round(2)]
      end
      count_sum = @sale_item_list.count.to_i + @sale_product_list.count.to_i
      sales_total = @sale_item_total.to_i + @sale_product_total.to_i
      csv.add_row []
      csv.add_row ["Total : #{count_sum}", '', '', convert_to_delimiter(sales_total)]
      csv.add_row []
      csv.add_row ['(Banam) Reciveable Details']
      csv.add_row ['(Banam) User List']
      csv.add_row %w[Code Name Group Balance]
      @last_group = @sys_user_receiveable.first.user_group if @sys_user_receiveable.present?
      @balance = 0
      @count = 0
      @sys_user_receiveable.each do |sys_user|
        if @last_group != sys_user.user_group
          csv.add_row ['', '', 'Total', convert_to_delimiter(@balance.round(2))]
          @last_group = sys_user.user_group
          @balance = 0
        end
        @count += 1
        csv.add_row [sys_user.code, sys_user.name, sys_user.user_group, convert_to_delimiter(sys_user.balance.abs)]
        @balance += sys_user.balance.round(2).abs
        if @sys_user_receiveable.last.code.eql?(sys_user.code)
          csv.add_row []
          csv.add_row ['', '', 'Total', convert_to_delimiter(@balance.round(2))]
          @balance = 0
        end
      end
      csv.add_row []
      csv.add_row ['Total', @count, '', convert_to_delimiter(@sys_user_receiveable.pluck('balance').map(&:abs).sum)]
      csv.add_row []
      csv.add_row ['(Jama) Staff List']
      csv.add_row %w[Code Name Department Balance]
      @last_department = @staff_reciveable.first.department if @staff_reciveable.present?
      @balance = 0
      @count = 0
      @staff_reciveable.each do |staff|
        if @last_department != staff.department
          csv.add_row ['', '', 'Total', convert_to_delimiter(@balance.round(2))]
          @last_department = staff.department
          @balance = 0
        end
        @count += 1
        dep = staff.department.present? ? staff.department.title : ''
        raw = staff.staff_raw_products.present? ? staff.staff_raw_products_titles : ''
        csv.add_row [staff.code, staff.full_name, "#{dep}:#{raw}", convert_to_delimiter(staff.balance.abs)]
        @balance += staff.balance.round(2).abs
        if @staff_reciveable.last.code == staff.code
          csv.add_row []
          csv.add_row ['Total', @staff_reciveable.count, '', convert_to_delimiter(@balance.round(2))]
          @balance = 0
        end
      end
      csv.add_row []
      csv.add_row ['Total', @count, '', convert_to_delimiter(@staff_reciveable.pluck('balance').map(&:abs).sum)]
      csv.add_row []
      csv.add_row ['(Banam) Expense List']
      csv.add_row %w[Title Amount Title Amount]
      @expense_list.each_slice(2) do |s|
        csv.add_row [s.first.first, s.first.last.to_f.round(2), s.last.first, s.last.last.to_f.round(2)]
      end
      csv.add_row ["Total : #{@expense_list.count}", '', '', convert_to_delimiter(@expense_total)]
      csv.add_row []
      csv.add_row ['(Banam) Investment List']
      csv.add_row %w[Title Amount]
      csv.add_row ['Investment', convert_to_delimiter(@investments.to_f.round(2))]
      csv.add_row ['Total', convert_to_delimiter(@investments.to_i)]
      csv.add_row []
      csv.add_row ['(Banam) Purchase List']
      csv.add_row %w[Title Amount Title Amount]
      @purchase_item_list.each_slice(2) do |s|
        csv.add_row [s.first.first, s.first.last.to_f.round(2), s.last.first, s.last.last.to_f.round(2)]
      end
      @purchase_product_list.each_slice(2) do |s|
        csv.add_row [s.first.first, s.first.last.to_f.round(2), s.last.first, s.last.last.to_f.round(2)]
      end
      count_sum = @purchase_item_list.count.to_i + @purchase_product_list.count.to_i
      purchase_total = @purchase_item_total.to_i + @purchase_product_total.to_i
      csv.add_row []
      csv.add_row ["Total : #{count_sum}", '', '', convert_to_delimiter(purchase_total)]
      csv.add_row []
      csv.add_row ['(Banam) Salary List']
      csv.add_row %w[Title Amount]
      @salary_detail_list.each { |s| csv.add_row [s.first, s.last.to_f.round(2)] if staff.last.positive? }
      kharkar = @salary_detail_kharkar
      csv.add_row ['Kharkar', convert_to_delimiter(kharkar.to_f.round(2))] if kharkar.positive?
      csv.add_row ["Total : #{@salary_detail_list.count}", convert_to_delimiter(@salary_detail_total)]
      csv.add_row []
      csv.add_row ['(Banam) Credit Salary List']
      csv.add_row %w[Title Amount Title Amount]
      @credit_salary_list.each_slice(2) do |s|
        csv.add_row [s.first.first, s.first.last.to_f.round(2), s.last.first, s.last.last.to_f.round(2)]
      end
      csv.add_row ["Total : #{@credit_salary_list.count}", '', '', convert_to_delimiter(@credit_salary)]
      csv.add_row []
      csv.add_row ['Discount Sale']
      csv.add_row %w[Title Amount]
      discount_list = @purchase_sale_detail_discount_list
      discount_list.each { |s| csv.add_row [s.sys_user.name, convert_to_delimiter(s.discount_price.to_f.round(2))] }
      csv.add_row ["Total : #{discount_list.count}", convert_to_delimiter(discount_list.sum(:discount_price))]
      csv.add_row []
      @total_receiveable = @sys_user_receiveable.pluck('balance').map(&:abs).sum + @staff_reciveable.sum(:balance).abs + @expense_total.to_i+@purchase_item_total.to_i+@purchase_product_total.to_i+@salary_detail_total.to_i+@credit_salary.to_i+@investments.to_i+@purchase_sale_detail_discount_list.sum(:discount_price)
      @total_payable = @sys_user_payable.pluck('balance').map(&:abs).sum + @staff_payable.sum(:balance).abs + @sale_item_total.to_i+@sale_product_total.to_i
      csv.add_row ['Cash in Hand = Payable-Reciveable']
      csv.add_row %w[Title Total]
      csv.add_row ['Payable', convert_to_delimiter(@total_payable.to_f.round(2))]
      csv.add_row ['Reciveable', convert_to_delimiter(@total_receiveable.to_f.round(2))]
      csv.add_row ['Total', convert_to_delimiter((@total_payable - @total_receiveable).to_f.round(2))]
      csv.add_row []
      csv.add_row ['Account List']
      csv.add_row %w[Title Amount]
      @accounts.each { |s| csv.add_row [s.title, convert_to_delimiter(s.amount.to_f.round(2))] }
      csv.add_row ["Total : #{@accounts.count}", convert_to_delimiter(@accounts.sum(:amount))]
    end
  end

  def products_csv
    @date = Date.today
    @time = Time.zone.now
    CSV.generate do |csv|
      csv.add_row [
        'Printing Date Time ', "#{@time.strftime('%d')} #{@time.strftime('%b')} #{@time.strftime('%y')}",
        @time.strftime('%I:%M%p')
      ]
      csv.add_row ['Report by', current_user.name]
      csv.add_row []
      csv.add_row ['Unit/Inventory Detail']
      csv.add_row []
      products_csv_staff(csv) if params[:csv_staff].present?
      products_csv_staff_with(csv) if params[:csv_staff_with].present?
    end
  end

  def products_csv_staff(csv)
    csv.add_row ['Title', 'Area', 'PerMarla', 'PerSFT', 'Unit Total', 'Total + Extra', 'Received Amount', 'Recevied %', 'Balance Amount', 'Balance %', 'Dealer', 'Sale To']
    total_and_extra_sum = 0.0
    @products.each do |product|
      staff_deal_orders = product.orders
      next unless staff_deal_orders.present?

      staff_deal_orders.each do |booking|
        token = booking.purchase_sale_details&.first
        a = [product&.title, "#{product.marla.to_i} Marla #{product.square_feet.to_i} Square Feet",
             convert_to_delimiter(product.sale.to_f / 225), convert_to_delimiter(product.sale)]
        per_sft = convert_to_delimiter(product.sale.to_f.round(2) * (product.marla.to_f + (product.square_feet.to_f / 225)))
        row = [a[0], a[1], a[2], per_sft, a[3]]
        if booking&.status != 'Cancel'
          va = ''
          amounts = booking.sys_user.ledger_books.pluck('SUM(debit)', 'SUM(credit)').first
          total_and_extra = [amounts].map { |sys| convert_to_delimiter(sys.first).to_s }.join(',').html_safe
          total_and_extra.to_s.split(',').map { |i| va += i }
          total_and_extra_sum += va.to_f
          rb_amounts = [amounts[1].to_s, (amounts[0].to_i - amounts[1].to_i).to_s]
          recevied_per = "#{((amounts[1].to_f / amounts[0].to_i) * 100).round(2)} %"
          balance_per = "#{(((amounts[0].to_i - amounts[1].to_i) / amounts[0].to_f) * 100).round(2)} %"
          dealer = token&.staff&.name
          sale_to = booking.sys_user.name
          row += [total_and_extra, rb_amounts[0], recevied_per, rb_amounts[1], balance_per, dealer, sale_to]
        else
          row += ["Cancel: #{booking.sys_user.name}"]
        end
        csv.add_row(row)
      end
    end
    total = "Total #{@products&.count}"
    area = "Marla: #{@total_marla} Square Feet: #{@total_square_feet}"
    price = convert_to_delimiter(@product_price)
    csv.add_row [total, area, '', price, '', convert_to_delimiter(total_and_extra_sum).to_s]
  end

  def products_csv_staff_with(csv)
    csv.add_row ['Item Type', 'Code', 'Title', 'Ctgy', 'Sub-ctgy', 'PerMarla', 'PerSFT', 'Total', 'Area',
                 'Unit Commission to', 'Customer Name', 'Total Amount', 'Paid', 'Paid in %', 'Remaining',
                 'Commission', 'Commission in %', 'Contact No', 'Last Payment Date', 'Booking-Canceled']
    @products.each do |product|
      a = [product&.item_type&.title, product&.code, product&.title, product&.product_category&.title,
           product&.product_sub_category&.title, convert_to_delimiter(product.sale),
           (product.sale.to_f / 225), "#{product.marla.to_i} Marla #{product.square_feet.to_i} Square Feet"]
      total = convert_to_delimiter(product.sale.to_f.round(2) * (product.marla.to_f + (product.square_feet.to_f / 225))).to_s
      row = [a[0], a[1], a[2], a[3], a[4], a[5], convert_to_delimiter(a[6]).to_s, total, a[7]]
      staff_deal_orders = product.orders
      next unless staff_deal_orders.present?

      staff_deal_orders.each do |booking|
        token = booking.purchase_sale_details&.first
        last_pay = booking&.sys_user&.ledger_books&.last&.created_at
        last_pay = last_pay.present? ? last_pay.strftime('%d %b %y at %I:%M%p').to_s.html_safe : ''
        sys = booking.sys_user.ledger_books.pluck('SUM(debit)', 'SUM(credit)').first
        paid_in_per = ((sys[1] / sys[0]) * 100).round(2).to_s
        commission_in_per = ((token&.carriage.to_f / sys[0]) * 100).round(2).to_s
        row += [token&.staff&.name, booking.sys_user.name, sys[0].to_s, sys[1].to_s, paid_in_per,
                (sys[0].to_i - sys[1].to_i).to_s, token&.carriage.to_s, commission_in_per,
                booking.sys_user.contact.phone_with_comma, last_pay]
        row.push('True') if booking&.status == 'Cancel'
        csv.add_row row
      end
    end
    price = convert_to_delimiter(@product_price).to_s
    area = "Marla: #{@total_marla} Square Feet: #{@total_square_feet}"
    csv.add_row ['Total', @products&.count, '', '', '', '', '', price, area]
  end

  def convert_to_delimiter(number)
    ActiveSupport::NumberHelper.number_to_delimited(number.to_f.round(2))
  end
end
