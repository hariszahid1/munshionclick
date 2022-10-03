class AddUserColumnToAccounts < ActiveRecord::Migration[5.2]
  def change
    add_reference :accounts, :user
  end
end
