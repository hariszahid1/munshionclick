class CreateOrderItems < ActiveRecord::Migration[5.2]
  def change
    create_table :order_items do |t|
      t.references :order
      t.references :product
      t.references :item
      t.float :quantity
      t.float :cost_price
      t.float :sale_price
      t.float :total_cost_price
      t.float :total_sale_price
      t.integer :status
      t.string :comment
      t.integer :transaction_type
      t.float :discount_price
      t.integer :purchase_sale_type
      t.datetime :expiry_date

      t.timestamps
    end
  end
end
