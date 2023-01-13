class AddQrCodeInPurchaseSaleDetails < ActiveRecord::Migration[6.1]
  def change
    add_column :purchase_sale_details, :qr_code, :text, if_not_exists: true
  end
end
