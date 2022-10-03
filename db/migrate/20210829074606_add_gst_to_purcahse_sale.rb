class AddGstToPurcahseSale < ActiveRecord::Migration[5.2]
  def change
    add_column :purchase_sale_items, :gst, :decimal
    add_column :purchase_sale_items, :gst_amount, :decimal
    add_column :purchase_sale_details, :with_gst, :integer
  end
end
