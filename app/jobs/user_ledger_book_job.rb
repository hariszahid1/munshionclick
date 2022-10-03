class UserLedgerBookJob < ActiveJob::Base
 queue_as :default
  def perform(db_name,sys_user_id)
    return unless sys_user_id.present?
    ActiveRecord::Base.establish_connection "#{Rails.env}_#{db_name}".to_sym
    sys_user = SysUser.find(sys_user_id)
    balance=sys_user.opening_balance.present? ? sys_user.opening_balance : 0
    LedgerBook.where(sys_user_id: sys_user.id).each do |lb|
      balance=(balance+lb.credit.to_i)-lb.debit.to_i
      if lb.balance!=balance
        lb.balance=balance
        lb.save!
      end
    end
    sys_user.update(balance: balance)
    # @sys_user.ledger_books.last.update_account_balance
      # product_stock=Product.group(:id).sum(:stock)
      # puts product_stock.to_s
    # end# databases end
  end
end
