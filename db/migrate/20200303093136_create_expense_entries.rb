class CreateExpenseEntries < ActiveRecord::Migration[5.0]
  def change
    create_table :expense_entries do |t|
      t.float :amount
      t.references :expense
      t.references :expense_type
      t.references :account
      t.text :comment
      t.integer :status

      t.timestamps
    end
  end
end
