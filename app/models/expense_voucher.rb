class ExpenseVoucher < ApplicationRecord
  belongs_to :expense_type, optional: true
  has_many :expense_entry_vouchers, dependent: :destroy
  has_many :expenses, dependent: :destroy

  accepts_nested_attributes_for :expense_entry_vouchers, reject_if: :all_blank, allow_destroy: true

  has_paper_trail ignore: [:updated_at]

end
