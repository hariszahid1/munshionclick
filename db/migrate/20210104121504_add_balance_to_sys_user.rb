class AddBalanceToSysUser < ActiveRecord::Migration[5.2]
  def change
    add_column :sys_users, :balance, :float
  end
end
