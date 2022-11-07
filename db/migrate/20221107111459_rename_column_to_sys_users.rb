class RenameColumnToSysUsers < ActiveRecord::Migration[6.1]
  def up
    rename_column :sys_users, :user_group_id, :user_group
  end

  def down
    rename_column :sys_users, :user_group_id, :user_group
  end

end
