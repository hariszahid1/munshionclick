class AddPurchaseSaleTypeToPurchaseSaleItems < ActiveRecord::Migration[5.0]
  def change
    add_column :purchase_sale_items, :purchase_sale_type, :integer, default: 0
  end
end
