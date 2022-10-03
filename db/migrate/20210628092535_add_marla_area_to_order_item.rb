class AddMarlaAreaToOrderItem < ActiveRecord::Migration[5.2]
  def change
    add_column :order_items, :marla, :float
    add_column :order_items, :square_feet, :float
  end
end
