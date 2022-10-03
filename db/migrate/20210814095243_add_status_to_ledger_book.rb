class AddStatusToLedgerBook < ActiveRecord::Migration[5.2]
  def change
    add_column :ledger_books, :status, :integer
    add_column :staff_ledger_books, :status, :integer
  end
end
