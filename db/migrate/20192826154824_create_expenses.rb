class CreateExpenses < ActiveRecord::Migration[5.0]
  def change
    create_table :expenses do |t|
      t.integer :expense
      t.text :comment
      t.references :expense_type, foreign_key: true
      t.timestamps
    end
  end
end
