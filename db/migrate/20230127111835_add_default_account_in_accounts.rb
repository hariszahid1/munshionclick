class AddDefaultAccountInAccounts < ActiveRecord::Migration[6.1]
  def change
    add_column :accounts, :default_account, :boolean, default: false, if_not_exists: true
  end
end
