class AccountPaymentJob < ActiveJob::Base
  queue_as :default
  def perform(db_name,account_id)
    return unless account_id.present?
    ActiveRecord::Base.establish_connection "#{Rails.env}_#{db_name}".to_sym
    account = Account.find(account_id)
    if account.present?
      payments = Payment.where(account_id: account_id)
      balance = payments.select('SUM(debit) as sum_debit','SUM(credit) as sum_credit','SUM(credit)-SUM(debit) as mean_sum').first.mean_sum
      payments.order('id desc' , 'created_at desc').first(100).each do |lb|
        if lb.amount != balance
          lb.amount = balance
          lb.save!
        end
        balance = balance.to_f+(lb.debit.to_f-lb.credit.to_f)
      end
      payments = Payment.where(account_id: account_id)
      balance = payments.select('SUM(debit) as sum_debit','SUM(credit) as sum_credit','SUM(credit)-SUM(debit) as mean_sum').first.mean_sum
      account.update(amount:balance)
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
