class AddBillNumberToPurchaseSaleDetail < ActiveRecord::Migration[5.2]
  def change
    add_column :purchase_sale_details, :bill_no, :string
  end
end
