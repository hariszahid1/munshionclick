class UserLedgerBookJob < ActiveJob::Base
 queue_as :default
  def perform(db_name,sys_user_id)
    return unless sys_user_id.present?
    ActiveRecord::Base.establish_connection "#{Rails.env}_#{db_name}".to_sym

    # sys_user = SysUser.find(sys_user_id)
    # balance=sys_user.opening_balance.present? ? sys_user.opening_balance : 0
    # LedgerBook.where(sys_user_id: sys_user.id).each do |lb|
    #   balance=(balance+lb.credit.to_i)-lb.debit.to_i
    #   if lb.balance!=balance
    #     lb.balance=balance
    #     lb.save!
    #   end
    # end
    # sys_user.update(balance: balance)

    sys_user = SysUser.find(sys_user_id)
    return unless sys_user.present?
    ledger_books = LedgerBook.where(sys_user_id: sys_user).order('id desc', 'created_at desc')
    balance = ledger_books.select('SUM(debit) as sum_debit','SUM(credit) as sum_credit','SUM(credit)-SUM(debit) as mean_sum').first.mean_sum
    sys_user.update(balance: balance)
    ledger_books = ledger_books.first(100)
    ledger_books.each do |lb|
      if lb.balance!=balance
        lb.balance=balance
        lb.save!
      end
      balance=balance.to_f+(lb.debit.to_f-lb.credit.to_f)
    end

    # @sys_user.ledger_books.last.update_account_balance
      # product_stock=Product.group(:id).sum(:stock)
      # puts product_stock.to_s
    # end# databases end
  end
end
