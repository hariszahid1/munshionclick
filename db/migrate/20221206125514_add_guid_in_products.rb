class AddGuidInProducts < ActiveRecord::Migration[6.1]
  def change
    add_column :products, :guid, :string

    product = []
    Product.all.each do |record|
      loop do
        guid = SecureRandom.hex(6)
        unless product.pluck(:guid).include?(guid)
          record.guid = guid
          break
        end
      end
      product << record
    end
    Product.import product, on_duplicate_key_update: [:id, :guid]
  end
end
