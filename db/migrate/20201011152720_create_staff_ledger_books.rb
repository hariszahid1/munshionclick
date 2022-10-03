class CreateStaffLedgerBooks < ActiveRecord::Migration[5.2]
  def change
    create_table :staff_ledger_books do |t|
      t.references :staff
      t.references :salary
      t.references :salary_detail
      t.float :debit
      t.float :credit
      t.float :balance
      t.text :comment

      t.timestamps
    end
  end
end
