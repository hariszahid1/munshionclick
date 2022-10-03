class CreatePayments < ActiveRecord::Migration[5.0]
  def change
    create_table :payments do |t|
      t.float :debit
      t.float :credit
      t.references :account
      t.references :paymentable, polymorphic: true
      t.float :amount
      t.integer :status
      t.text :comment
      t.timestamps
    end
  end
end
