class AddOrderToLedgerBook < ActiveRecord::Migration[5.2]
  def change
    add_reference :ledger_books, :order
  end
end
