class AddOrderNumberToPurchaseSaleDetail < ActiveRecord::Migration[5.0]
  def change
    add_column :purchase_sale_details, :voucher_id, :integer
  end
end
