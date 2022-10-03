class CreateExpenseTypes < ActiveRecord::Migration[5.0]
  def change
    create_table :expense_types do |t|
      t.string :title
      t.string :comment

      t.timestamps
    end
  end
end
