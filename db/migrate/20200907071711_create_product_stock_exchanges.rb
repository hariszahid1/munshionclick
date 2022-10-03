class CreateProductStockExchanges < ActiveRecord::Migration[5.2]
  def change
    create_table :product_stock_exchanges do |t|
      t.references :product
      t.integer :product_recipient_id
      t.integer :quantity
      t.timestamps
    end
  end
end
