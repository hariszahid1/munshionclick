class PaymentBalanceJob < ActiveJob::Base
  queue_as :default
  def perform(db_name,account_id)
    return unless account_id.present?
    ActiveRecord::Base.establish_connection "#{Rails.env}_#{db_name}".to_sym
    puts "----------------------------CashInHand----------------------------------"
    @pos_setting = PosSetting.last
    if @pos_setting.present?
      @account_balance = Account.group(:title).sum(:amount)
      @account_amount_total = Account.sum(:amount)
      @sys_user_payable_group_total = SysUser.where('balance > 0').sum(:balance)
      @sys_user_receiveable_group_total = SysUser.where('balance < 0').sum(:balance)
      @staff_payable_group_total = Staff.where('balance>0').where(deleted: false).sum(:balance)
      @staff_reciveable_group_total = Staff.where('balance<0').where(deleted: false).sum(:balance)
      @sale_product_total = PurchaseSaleItem.joins(:product).where(transaction_type:'Sale').sum(:total_sale_price)
      @expense_total = ExpenseEntry.sum(:amount)
      @investments_debit = Investment.sum(:debit)
      @investments_credit = Investment.sum(:credit)
      @purchase_sale_detail_discount_list = PurchaseSaleDetail.where(transaction_type:'Sale').where.not(discount_price:[nil,0]).sum(:discount_price)
      @credit_salary = SalaryDetail.joins(:staff).where('amount>0').where(purchase_sale_detail_id:nil,daily_book_id:nil).where.not(id: Payment.where(paymentable_type:"SalaryDetail").pluck(:paymentable_id)).sum(:amount).to_f
      if @pos_setting.sys_type == 'batha'
        @salary_detail_total = SalaryDetail.joins(staff: :department).where(comment:["Payment Credit",nil]).where.not('departments.id>=4').sum(:amount)+SalaryDetail.joins(staff: :department).where(comment:["Payment Credit",nil]).where('khakar_credit>0').where.not('departments.id=4').sum(:khakar_credit)
      else
        @salary_detail_total = SalaryDetail.joins(staff: :department).where(comment:["Payment Credit",nil]).where.not('departments.id=4').sum(:amount)+SalaryDetail.joins(staff: :department).where(comment:["Payment Credit",nil]).where('khakar_credit>0').where.not('departments.id=4').sum(:khakar_credit)
      end

      @credit_salary =     SalaryDetail.joins(:staff).where('amount>0').where(purchase_sale_detail_id:nil,daily_book_id:nil).where.not(id: Payment.where(paymentable_type:"SalaryDetail").pluck(:paymentable_id)).sum(:amount).to_f
      @purchase_item_total = PurchaseSaleItem.joins(:item).where(transaction_type:'Purchase').sum(:total_cost_price)
      @purchase_product_total = PurchaseSaleItem.joins(:product).where(transaction_type:'Purchase').sum(:total_cost_price)

      @total_payable = @sys_user_payable_group_total + @staff_payable_group_total + @sale_product_total +
                       @investments_credit
      @total_reciveable = @sys_user_receiveable_group_total.abs + @staff_reciveable_group_total.abs + @expense_total +
                          @investments_debit + @salary_detail_total + @credit_salary +
                          @purchase_sale_detail_discount_list + @purchase_item_total + @purchase_product_total
      PosSetting.last.update(cash_in_hand: (@total_payable.to_i - @total_reciveable.to_i))
      puts "----------------------------CashInHand----------------------------------"
    end
  end #def perfom end

end
# balance=0
# Payment.where(account_id: account.id).each do |lb|
#   balance=balance+lb.credit.to_f-lb.debit.to_f
#   if lb.amount!=balance
#     lb.amount=balance
#     lb.save!
#   end #if end
# end  #Payment Loop end
# account.update(amount:balance)
