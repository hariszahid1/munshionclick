class AddSysUserBalance < ActiveRecord::Migration[5.2]
  def change
    SysUser.all.each_with_index do |sys,index|
      if sys.ledger_books.present?
        sys.update(balance: sys.ledger_books.last.balance)
      else
        sys.update(balance: sys.opening_balance)
      end
    end
  end
end
