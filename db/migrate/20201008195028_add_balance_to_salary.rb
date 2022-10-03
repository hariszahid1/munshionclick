class AddBalanceToSalary < ActiveRecord::Migration[5.2]
  def change
    add_column :salaries, :balance, :float
    add_column :salaries, :total_balance, :float
  end
end
