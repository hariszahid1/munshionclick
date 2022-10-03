class AddColumnOrderSaleItems < ActiveRecord::Migration[6.1]
  def change
    add_column :order_items, :extra_expence, :float
  end
end
