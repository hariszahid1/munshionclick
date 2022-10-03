class AddRolesMaskToUsers < ActiveRecord::Migration[5.0]
  def change
    add_column :users, :roles_mask, :integer, default: nil
  end
end
