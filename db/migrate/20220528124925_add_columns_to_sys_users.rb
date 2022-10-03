class AddColumnsToSysUsers < ActiveRecord::Migration[6.1]
  def change
    add_column :sys_users, :father,  :string
    add_column :sys_users, :nom_name,  :string
    add_column :sys_users, :nom_father,  :string
    add_column :sys_users, :nom_cnic,  :string
    add_column :sys_users, :nom_relation,  :string
  end
end
