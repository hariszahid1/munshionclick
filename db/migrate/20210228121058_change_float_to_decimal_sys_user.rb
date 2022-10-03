class ChangeFloatToDecimalSysUser < ActiveRecord::Migration[5.2]
  def change
    change_column :sys_users, :balance, :decimal, precision: 15, scale: 2
    change_column :sys_users, :opening_balance, :decimal, precision: 15, scale: 2
    change_column :sys_users, :credit_limit, :decimal, precision: 15, scale: 2    
  end
end
