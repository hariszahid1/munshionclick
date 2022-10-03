class AddQuantityTypeToItem < ActiveRecord::Migration[5.0]
  def change
    add_column :items, :quantity_type, :integer
    add_column :items, :weight_type, :integer
  end
end
