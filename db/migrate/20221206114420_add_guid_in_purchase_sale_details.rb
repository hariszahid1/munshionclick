class AddGuidInPurchaseSaleDetails < ActiveRecord::Migration[6.1]
  def change
    add_column :purchase_sale_details, :guid, :string

    psh = []
    PurchaseSaleDetail.all.each do |record|
      loop do
        guid = SecureRandom.hex(6)
        unless psh.pluck(:guid).include?(guid)
          record.guid = guid
          break
        end
      end
      psh << record
    end
    PurchaseSaleDetail.import psh, on_duplicate_key_update: [:id, :guid]
  end
end
