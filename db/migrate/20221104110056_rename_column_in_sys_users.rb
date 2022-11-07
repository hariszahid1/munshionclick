class RenameColumnInSysUsers < ActiveRecord::Migration[6.1]
  def up
    rename_column :sys_users, :user_group, :user_group_id
  end

  def down
    rename_column :sys_users, :user_group, :user_group_id
  end
end
