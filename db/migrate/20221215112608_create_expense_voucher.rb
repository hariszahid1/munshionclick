class CreateExpenseVoucher < ActiveRecord::Migration[6.1]
  def change
    create_table :expense_vouchers do |t|
      t.float :expense
      t.text :comment
      t.references :expense_type

      t.timestamps
    end
  end
end
