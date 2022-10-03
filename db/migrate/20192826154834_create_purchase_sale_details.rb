class CreatePurchaseSaleDetails < ActiveRecord::Migration[5.0]
  def change
    create_table :purchase_sale_details do |t|
      t.references :sys_user, foreign_key: true
      t.integer :transaction_type
      t.integer :total_bill
      t.integer :amount
      t.integer :discount_price
      t.integer :status
      t.string :comment

      t.timestamps
    end
  end
end
