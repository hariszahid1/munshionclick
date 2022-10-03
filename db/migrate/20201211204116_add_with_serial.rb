class AddWithSerial < ActiveRecord::Migration[5.2]
  def change
    add_column :products, :with_serial, :boolean
  end
end
