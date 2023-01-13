class AddColdStorageFieldsInOrderItems < ActiveRecord::Migration[6.1]
  def change
    add_column :order_items, :marka, :string, if_not_exists: true
    add_column :order_items, :vehicle_no, :string, if_not_exists: true
    add_column :order_items, :builty_no, :string, if_not_exists: true
    add_column :order_items, :challan_no, :string, if_not_exists: true
  end
end
