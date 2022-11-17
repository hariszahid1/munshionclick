class Investment < ApplicationRecord
  belongs_to :account
  has_many :payment, as: :paymentable, dependent: :destroy
  after_create :modify_account_balance
  after_update :modify_account_balance

  has_paper_trail ignore: [:updated_at]

  def modify_account_balance
    if self.account_id?
      if self.payment.present?
        self.payment.update_all(account_id: self.account_id,credit: self.credit.to_f, debit: self.debit.to_i,comment: "Edited Investment", created_at: self.created_at)
      else
				if self.debit.present?
	        self.payment.create(account_id: self.account_id,debit: self.debit.to_i,comment: "Investment", created_at: self.created_at)	
				elsif self.credit.present?
					self.payment.create(account_id: self.account_id,credit: self.credit.to_i,comment: "Investment", created_at: self.created_at)
				end
			end
    end
  end

end
