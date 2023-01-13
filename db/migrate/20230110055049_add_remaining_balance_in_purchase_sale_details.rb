class AddRemainingBalanceInPurchaseSaleDetails < ActiveRecord::Migration[6.1]
  def change
    add_column :purchase_sale_details, :remaining_balance, :decimal, if_not_exists: true
  end
end
