class ExpenseEntry < ApplicationRecord
  belongs_to :expenseable, polymorphic: true, optional:true
  belongs_to :expense, optional: true
  belongs_to :expense_type
  belongs_to :account
  has_many :payment, as: :paymentable, dependent: :destroy

  after_create :modify_account_balance
  after_update :modify_account_balance
  has_paper_trail ignore: [:updated_at]
  def modify_account_balance
    if self.account_id?
      if self.payment.present?
        self.payment.update_all(account_id: self.account_id,debit:self.amount.to_i,comment: "Edited Expense", created_at: self.created_at)
      else
        self.payment.create(account_id: self.account_id,debit:self.amount.to_i,comment: "Expense", created_at: self.created_at)
      end
    end
  end


end
