class AddStockToProduct < ActiveRecord::Migration[5.0]
  def change
    add_column :products, :stock, :float, default: 0
    add_column :products, :location, :string
  end
end
