class ChangeFloatToDecimal < ActiveRecord::Migration[5.2]
  def change
    change_column :payments, :amount, :decimal
    change_column :payments, :debit, :float
    change_column :payments, :credit, :float

    change_column :accounts, :amount, :decimal
    change_column :staffs, :balance, :decimal
    change_column :staffs, :wage_debit, :float
    change_column :staffs, :wage_rate, :float
    change_column :staffs, :advance_amount, :float
    change_column :staffs, :monthly_salary, :float

  end
end
