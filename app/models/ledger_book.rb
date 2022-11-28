class LedgerBook < ApplicationRecord
  belongs_to :sys_user
  belongs_to :purchase_sale_detail, optional: true
  belongs_to :account, optional: true
  has_many :payments, as: :paymentable, dependent: :destroy
  belongs_to :order, optional: true
  after_create :sys_user_balance_change
  after_update :sys_user_balance_change
  after_destroy :sys_user_balance_change

  has_paper_trail ignore: [:updated_at,:balance]

  def modify_account_balance
    if self.account_id? && self.sys_user_id? && self.purchase_sale_detail_id.blank?
      # if self.sys_user.user_group=="Supplier" || self.sys_user.user_group=="Both"
        # self.payments.create(account_id: self.account_id,debit: credit.to_i, credit: debit.to_i,comment: "Supplier/Both Payment")
        self.payments.create(account_id: self.account_id,debit: debit.to_f, credit: credit.to_f,comment: "Supplier/Both Payment")
      # else
        # self.payments.create(account_id: self.account_id,debit:credit.to_i, credit: debit.to_i,comment: "Customer Payment")
      # end
    end
  end

  def update_account_balance
    if self.account_id? && self.sys_user_id? && self.purchase_sale_detail_id.blank?
        # if self.sys_user.user_group=="Supplier" || self.sys_user.user_group=="Both"
      self.payments.update_all(account_id: self.account_id,debit: debit.to_f, credit: credit.to_f,comment: "Supplier/Both Edited Payment")
      # else
        # self.payments.update_all(account_id: self.account_id,debit:credit.to_i, credit: debit.to_i,comment: "Customer Edited Payment")
      # end
      # balance=0
      # Payment.where(account_id: self.account_id).each do |lb|
      #   balance=balance+lb.credit.to_i-lb.debit.to_i
      #   if lb.amount!=balance
      #     lb.amount=balance
      #     lb.save!
      #   end
      # end
      balance = self.account.payments.sum(:credit)-self.account.payments.sum(:debit)
      self.account.update(amount:balance)
    end
  end

  def sys_user_balance_change
    balance = self&.sys_user&.opening_balance.to_f+(self&.sys_user&.ledger_books.sum(:credit)-self&.sys_user&.ledger_books.sum(:debit))
    self.sys_user.update(balance: balance)
  end
end
