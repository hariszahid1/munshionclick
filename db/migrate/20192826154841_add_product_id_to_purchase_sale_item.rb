class AddProductIdToPurchaseSaleItem < ActiveRecord::Migration[5.0]
  def change
    add_reference :purchase_sale_items, :product, foreign_key: true
  end
end
