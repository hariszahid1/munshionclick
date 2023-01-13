class AddReferenceExpenseVoucherInExpenses < ActiveRecord::Migration[6.1]
  def change
    add_reference :expenses, :expense_voucher, if_not_exists: true
		rename_column :expense_vouchers, :expense, :amount
  end
end
