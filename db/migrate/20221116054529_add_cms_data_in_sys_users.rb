class AddCmsDataInSysUsers < ActiveRecord::Migration[6.1]
  def change
    add_column :sys_users, :cms_data, :json
  end
end
