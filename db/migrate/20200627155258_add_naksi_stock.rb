class AddNaksiStock < ActiveRecord::Migration[5.2]
  def change
    add_column :raw_products, :nakasi_stock, :integer, default: 0 # nakasi stock
  end
end
 
