class AddSuffixInSysUsers < ActiveRecord::Migration[6.1]
  def change
    add_column :sys_users, :suffix, :string, if_not_exists: true
  end
end
