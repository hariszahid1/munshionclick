class Account < ApplicationRecord
  include CashInHandMethod

  has_many :account
  has_many :payments
  has_one_attached :profile_image
  after_create :new_payment
  belongs_to :user, optional: true
  has_paper_trail ignore: [:updated_at]
  after_commit :cash_in_hand

  def new_payment
     amount = self.amount.to_i
     self.amount=0
     self.save!
     self.payments.create(account_id: self.id,credit: amount,comment: "Opening Balance")
  end
end
