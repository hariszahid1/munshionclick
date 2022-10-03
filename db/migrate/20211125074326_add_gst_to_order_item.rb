class AddGstToOrderItem < ActiveRecord::Migration[5.2]
  def change
    add_column :order_items, :gst, :decimal, precision: 15, scale: 2
    add_column :order_items, :gst_amount, :decimal, precision: 15, scale: 2
    add_column :orders, :with_gst, :integer
  end
end
