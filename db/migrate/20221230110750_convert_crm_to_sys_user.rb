class ConvertCrmToSysUser < ActiveRecord::Migration[6.1]
  def change
    add_column :sys_users, :for_crms, :boolean
  end
end
