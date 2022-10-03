class ChangeFloatToDecimalAll < ActiveRecord::Migration[5.2]
  def change

    change_column :payments, :amount, :decimal, precision: 15, scale: 5
    change_column :payments, :debit, :decimal, precision: 15, scale: 5
    change_column :payments, :credit, :decimal, precision: 15, scale: 5

    change_column :accounts, :amount, :decimal, precision: 15, scale: 5

    change_column :staffs, :balance, :decimal, precision: 15, scale: 5
    change_column :staffs, :wage_debit, :decimal, precision: 15, scale: 5
    change_column :staffs, :wage_rate, :decimal, precision: 15, scale: 5
    change_column :staffs, :advance_amount, :decimal, precision: 15, scale: 5
    change_column :staffs, :monthly_salary, :decimal, precision: 15, scale: 5

    change_column :staff_ledger_books, :debit, :decimal, precision: 15, scale: 5
    change_column :staff_ledger_books, :credit, :decimal, precision: 15, scale: 5
    change_column :staff_ledger_books, :balance, :decimal, precision: 15, scale: 5

    change_column :ledger_books, :debit, :decimal, precision: 15, scale: 5
    change_column :ledger_books, :credit, :decimal, precision: 15, scale: 5
    change_column :ledger_books, :balance, :decimal, precision: 15, scale: 5

    change_column :sys_users, :balance, :decimal, precision: 15, scale: 5
    change_column :sys_users, :opening_balance, :decimal, precision: 15, scale: 5
    change_column :sys_users, :credit_limit, :decimal, precision: 15, scale: 5

  end
end
