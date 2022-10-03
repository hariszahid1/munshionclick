class AddAccountIdToLedgerBook < ActiveRecord::Migration[5.0]
  def change
    add_reference :ledger_books, :account
  end
end
 
