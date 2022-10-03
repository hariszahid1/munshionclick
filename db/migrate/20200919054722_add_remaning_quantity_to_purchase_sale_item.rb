class AddRemaningQuantityToPurchaseSaleItem < ActiveRecord::Migration[5.2]
  def change
    add_column :purchase_sale_items, :remaining_quantity, :float
  end
end
