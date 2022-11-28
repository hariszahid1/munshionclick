class Payment < ApplicationRecord

  belongs_to :paymentable, polymorphic: true, optional:true
  belongs_to :account
  after_create :modify_account_balance
  before_destroy :remove_account_balance
  enum confirmable: %i[unconfirm confirmed]

  has_paper_trail ignore: [:updated_at]


  def modify_account_balance
    if self.account_id?
      total_balance = account.payments.sum(:credit)-account.payments.sum(:debit)
      account.update(amount: total_balance)
      self.amount=account.amount
      self.save!
    end
  end
  def remove_account_balance
    if self.account_id?
      total_balance = account.payments.sum(:credit)-account.payments.sum(:debit)
      account.update(amount: total_balance)
    end
  end

end
