class CreatePurchaseSaleItems < ActiveRecord::Migration[5.0]
  def change
    create_table :purchase_sale_items do |t|
      t.references :purchase_sale_detail, foreign_key: true
      t.references :item, foreign_key: true
      t.integer :quantity
      t.integer :cost_price
      t.integer :sale_price
      t.integer :total_cost_price
      t.integer :total_sale_price
      t.integer :status
      t.string :comment

      t.timestamps
    end
  end
end
