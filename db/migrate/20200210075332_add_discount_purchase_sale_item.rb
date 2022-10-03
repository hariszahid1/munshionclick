class AddDiscountPurchaseSaleItem < ActiveRecord::Migration[5.0]
  def change
    add_column :purchase_sale_items, :discount_price, :float, default: 0
  end
end
