class ExpenseType < ApplicationRecord
  has_many :expense_vouchers
  has_many :expense_entry_vouchers
  has_paper_trail ignore: [:updated_at]
  validates :title, presence: true, uniqueness: { case_sensitive: false }

end
