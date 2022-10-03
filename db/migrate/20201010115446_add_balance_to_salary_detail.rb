class AddBalanceToSalaryDetail < ActiveRecord::Migration[5.2]
  def change
    add_column :salary_details, :balance, :float
    add_column :salary_details, :total_balance, :float
  end
end
