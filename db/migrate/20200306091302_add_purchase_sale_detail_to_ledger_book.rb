class AddPurchaseSaleDetailToLedgerBook < ActiveRecord::Migration[5.0]
  def change
    add_reference :ledger_books, :purchase_sale_detail
  end
end
