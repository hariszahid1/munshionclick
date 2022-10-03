class ChangeWithGstToDecimal < ActiveRecord::Migration[5.2]
  def change
    change_column :purchase_sale_items, :gst, :decimal, precision: 15, scale: 2
    change_column :purchase_sale_items, :gst_amount, :decimal, precision: 15, scale: 2
  end
end
