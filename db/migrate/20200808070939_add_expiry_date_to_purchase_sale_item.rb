class AddExpiryDateToPurchaseSaleItem < ActiveRecord::Migration[5.2]
  def change
    add_column :purchase_sale_items, :expiry_date, :datetime
  end
end
