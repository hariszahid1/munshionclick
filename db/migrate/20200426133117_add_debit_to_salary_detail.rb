class AddDebitToSalaryDetail < ActiveRecord::Migration[5.2]
  def change
    add_column :salary_details, :wage_debit, :float
  end
end
