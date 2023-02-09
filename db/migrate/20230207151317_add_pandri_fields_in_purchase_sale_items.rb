class AddPandriFieldsInPurchaseSaleItems < ActiveRecord::Migration[6.1]
  def change
    add_column :purchase_sale_items, :panelty_pandri, :float, if_not_exists: true
    add_column :purchase_sale_items, :rent_pandri, :float, if_not_exists: true
    add_column :purchase_sale_items, :total_pandri_bill, :float, if_not_exists: true
  end
end
