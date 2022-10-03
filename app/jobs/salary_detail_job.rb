class SalaryDetailJob < ActiveJob::Base
 queue_as :default
  def perform(db_name,staff_id)
    return unless staff_id.present?
    ActiveRecord::Base.establish_connection "#{Rails.env}_#{db_name}".to_sym
    staff = Staff.find(staff_id)
    if staff.present?
      staff_ledger_books = StaffLedgerBook.joins(:staff).where(staff_id: staff_id).where('credit>0 or debit>0').order('staffs.name asc', 'staff_ledger_books.created_at desc')
      debit_credit_balance = staff_ledger_books.select('SUM(debit) as sum_debit','SUM(credit) as sum_credit','SUM(credit)-SUM(debit) as mean_sum').first
      credit = debit_credit_balance.sum_credit
      debit = debit_credit_balance.sum_debit
      balance = debit_credit_balance.sum_credit.to_f-debit_credit_balance.sum_debit.to_f
      staff.update_column(:balance, balance)
      staff_ledger_books = staff_ledger_books.first(500)
      staff_ledger_books.each do |lb|
        if lb.balance!=balance
          lb.balance=balance
          lb.save!
        end
        balance=balance.to_f+(lb.debit.to_f-lb.credit.to_f)
      end
    end
  end
end
# balance=0
# staff_ledger_books = StaffLedgerBook.joins(:staff).where(staff_id: staff.id).where('credit>0 or debit>0').order('staffs.name asc', 'staff_ledger_books.created_at asc')
# staff_ledger_books.each do |lb|
#   balance=balance.to_f+(lb.credit.to_f-lb.debit.to_f)
#   if lb.balance!=balance
#     lb.balance=balance
#     lb.save!
#   end
# end
