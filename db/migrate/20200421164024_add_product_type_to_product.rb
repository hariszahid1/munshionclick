class AddProductTypeToProduct < ActiveRecord::Migration[5.2]
  def change
    add_column :products, :product_type, :integer, default: 0
  end
end
