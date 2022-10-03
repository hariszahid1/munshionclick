class AddRawProductTileQuantityToStaff < ActiveRecord::Migration[5.2]
  def change
    add_column :staffs, :raw_product_quantity_tile, :float, default: 0
  end
end
