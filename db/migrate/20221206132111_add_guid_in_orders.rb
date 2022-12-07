class AddGuidInOrders < ActiveRecord::Migration[6.1]
  def change
    add_column :orders, :guid, :string

    order = []
    Order.all.each do |record|
      loop do
        guid = SecureRandom.hex(6)
        unless order.pluck(:guid).include?(guid)
          record.guid = guid
          break
        end
      end
      order << record
    end
    Order.import order, on_duplicate_key_update: [:id, :guid]
  end
end
