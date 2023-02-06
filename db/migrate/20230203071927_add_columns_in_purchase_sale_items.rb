class AddColumnsInPurchaseSaleItems < ActiveRecord::Migration[6.1]
  def change
    add_column :purchase_sale_items, :inward_date, :datetime, if_not_exists: true
    add_column :purchase_sale_items, :closed_date, :datetime, if_not_exists: true
  end
end
