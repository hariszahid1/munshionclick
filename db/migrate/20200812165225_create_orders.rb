class CreateOrders < ActiveRecord::Migration[5.2]
  def change
    create_table :orders do |t|
      t.references :sys_user
      t.integer :transaction_type
      t.float :total_bill
      t.float :amount
      t.float :discount_price
      t.integer :status
      t.string :comment
      t.integer :voucher_id
      t.references :account
      t.float :carriage
      t.float :loading

      t.timestamps
    end
  end
end
