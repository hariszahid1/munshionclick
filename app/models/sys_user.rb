class SysUser < ApplicationRecord
  has_one_attached :profile_image
  belongs_to :user_type
  has_one :contact
  has_many :ledger_books
  has_many :orders
  has_many :purchase_sale_details
  enum user_group: %i[Customer Supplier Both Salesman Own Investor Investment Worker Other LandLord MD-Investment]
  enum status: %i[Active Passive Deleted]
  accepts_nested_attributes_for :contact
  validates_uniqueness_of :code
  has_paper_trail ignore: [:updated_at, :balance]
  has_many :follow_ups, as: :followable
  has_many :notes, as: :notable
  accepts_nested_attributes_for :notes
  accepts_nested_attributes_for :follow_ups

  # def balance
    # balance=(LedgerBook.where(sys_user_id: id).present? ? LedgerBook.where(sys_user_id: id).last.balance : self.opening_balance).to_i
  # end

  after_create :balance_change, :sys_user_cms_data
  after_update :sys_user_cms_data
  before_save { ntn.downcase! }

  def balance_change
    self.update(balance: self.opening_balance)
  end

  ransacker :cms_data do
    Arel.sql("sys_users.cms_data")
  end

  def sys_user_cms_data
    data = {}
    cms_data.each do |k, v|
      next data[k] = v if k.eql? 'client_status'

      data[k] = v.downcase
    end
    update_columns(cms_data: data)
  end

end
