class AddExpenseFromToSalaryFromTo < ActiveRecord::Migration[5.2]
  def change
    add_column :gates, :expense_from, :datetime
    add_column :gates, :expense_to, :datetime
    add_column :gates, :salary_from, :datetime
    add_column :gates, :salary_to, :datetime
  end
end
