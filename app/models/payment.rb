class Payment < ApplicationRecord
  include CashInHandMethod

  belongs_to :paymentable, polymorphic: true, optional:true
  belongs_to :account
  after_create :modify_account_balance
  before_destroy :remove_account_balance
  enum confirmable: %i[unconfirm confirmed]

  has_paper_trail ignore: [:updated_at]
  after_commit :cash_in_hand


  def modify_account_balance
    if self.account_id?
      # already_balance = account.amount.present? ? account.amount : 0
      # if self.account_id.present? and self.debit.present? and self.credit.present? and self.debit>0 and self.credit>0
      #   total_balance = already_balance+self.credit.to_i-self.debit.to_i
      # elsif self.account_id.present? and self.credit.present? and self.credit>0
      #   total_balance = already_balance+self.credit.to_i
      # elsif self.account_id.present? and self.debit.present? and self.debit>0
      #   total_balance = already_balance-self.debit.to_i
      # else
      #   total_balance = already_balance
      # end
      # account.update(amount: total_balance)
      total_balance = account.payments.sum(:credit)-account.payments.sum(:debit)
      account.update(amount: total_balance)
      self.amount=account.amount
      self.save!
    end
  end
  def remove_account_balance
    if self.account_id?
      # already_balance = account.amount.present? ? account.amount : 0
      # if self.account_id? and self.debit.present? and self.credit.present?
      #   total_balance = already_balance-(self.credit.to_i+self.debit.to_i)
      # elsif self.account_id? and self.credit.present?
      #   total_balance = already_balance-self.credit.to_i
      # elsif self.account_id? and self.debit.present?
      #   total_balance = already_balance+self.debit.to_i
      # end
      total_balance = account.payments.sum(:credit)-account.payments.sum(:debit)
      account.update(amount: total_balance)
    end
  end

end
