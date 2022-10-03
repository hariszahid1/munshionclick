class BataShoeStockToProductPurchaseSaleItem < ActiveRecord::Migration[5.0]
  def change
    add_column :products, :size_1, :string, default: 0
    add_column :products, :size_2, :string, default: 0
    add_column :products, :size_3, :string, default: 0
    add_column :products, :size_4, :string, default: 0
    add_column :products, :size_5, :string, default: 0
    add_column :products, :size_6, :string, default: 0
    add_column :products, :size_7, :string, default: 0
    add_column :products, :size_8, :string, default: 0
    add_column :products, :size_9, :string, default: 0
    add_column :products, :size_10, :string, default: 0
    add_column :products, :size_11, :string, default: 0
    add_column :products, :size_12, :string, default: 0
    add_column :products, :size_13, :string, default: 0

    add_column :purchase_sale_items, :size_1, :string, default: 0
    add_column :purchase_sale_items, :size_2, :string, default: 0
    add_column :purchase_sale_items, :size_3, :string, default: 0
    add_column :purchase_sale_items, :size_4, :string, default: 0
    add_column :purchase_sale_items, :size_5, :string, default: 0
    add_column :purchase_sale_items, :size_6, :string, default: 0
    add_column :purchase_sale_items, :size_7, :string, default: 0
    add_column :purchase_sale_items, :size_8, :string, default: 0
    add_column :purchase_sale_items, :size_9, :string, default: 0
    add_column :purchase_sale_items, :size_10, :string, default: 0
    add_column :purchase_sale_items, :size_11, :string, default: 0
    add_column :purchase_sale_items, :size_12, :string, default: 0
    add_column :purchase_sale_items, :size_13, :string, default: 0
  end
end
