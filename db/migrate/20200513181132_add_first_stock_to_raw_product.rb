class AddFirstStockToRawProduct < ActiveRecord::Migration[5.2]
  def change
    add_column :raw_products, :first_stock, :integer, default: 0 # bkri stock
    add_column :raw_products, :second_stock, :integer, default: 0 # kacha stock
    add_column :raw_products, :third_stock, :integer, default: 0 # chapa stock
  end
end
