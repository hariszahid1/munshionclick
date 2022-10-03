class AddUserNameToPurchaseSaleDetail < ActiveRecord::Migration[5.2]
  def change
    add_column :purchase_sale_details, :user_name, :string
  end
end
