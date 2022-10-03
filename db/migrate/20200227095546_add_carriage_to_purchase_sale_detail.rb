class AddCarriageToPurchaseSaleDetail < ActiveRecord::Migration[5.0]
  def change
    add_column :purchase_sale_details, :carriage, :float, default: 0
  end
end
