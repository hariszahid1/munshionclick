class SysUser < ApplicationRecord
  has_one_attached :profile_image
  belongs_to :user_type
  has_one :contact
  has_many :ledger_books
  has_many :orders
  has_many :purchase_sale_details
  enum user_group: %i[Customer Supplier Both Salesman Own Investor Investment Worker Other LandLoad MD-Investment]
  enum status: %i[Active Passive Deleted]
  accepts_nested_attributes_for :contact
  validates_uniqueness_of :code

  has_paper_trail ignore: [:updated_at, :balance]

  # def balance
    # balance=(LedgerBook.where(sys_user_id: id).present? ? LedgerBook.where(sys_user_id: id).last.balance : self.opening_balance).to_i
  # end

  after_create :balance_change

  def balance_change
    self.update(balance: self.opening_balance)
  end

end
