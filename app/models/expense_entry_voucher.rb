class ExpenseEntryVoucher < ApplicationRecord
  belongs_to :expenseable, polymorphic: true, optional:true
  belongs_to :expense_voucher
  belongs_to :expense_type
end
