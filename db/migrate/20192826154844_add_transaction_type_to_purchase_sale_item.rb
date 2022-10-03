class AddTransactionTypeToPurchaseSaleItem < ActiveRecord::Migration[5.0]
  def change
    add_column :purchase_sale_items, :transaction_type, :integer
  end
end
