class CreateExpenseEntryVoucher < ActiveRecord::Migration[6.1]
  def change
    create_table :expense_entry_vouchers do |t|
      t.float :amount
      t.text :comment
      t.integer :status
      t.references :expense_voucher
      t.references :expense_type
      t.references :expenseable, polymorphic: true

      t.timestamps
    end
  end
end
