class AddRawQuantityToSalaryDetail < ActiveRecord::Migration[5.2]
  def change
    add_column :salary_details, :raw_quantity, :float
    add_column :salary_details, :raw_wage_rate, :float
    add_column :salary_details, :gift_rate, :float
    add_column :salary_details, :coverge_rate, :float

  end
end
