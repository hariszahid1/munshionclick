class ChangeCommentStringToText < ActiveRecord::Migration[6.1]
  def change
    change_column :cities, :comment, :text
    change_column :contacts, :comment, :text
    change_column :countries, :comment, :text
    change_column :daily_sales, :comment, :text
    change_column :expense_types, :comment, :text
    change_column :item_types, :comment, :text
    change_column :items, :comment, :text
    change_column :ledger_books, :comment, :text
    change_column :materials, :comment, :text
    change_column :order_items, :comment, :text
    change_column :orders, :comment, :text
    change_column :product_categories, :comment, :text
    change_column :product_sub_categories, :comment, :text
    change_column :productions, :comment, :text
    change_column :products, :comment, :text
    change_column :purchase_sale_details, :comment, :text
    change_column :purchase_sale_items, :comment, :text
    change_column :user_types, :comment, :text
  end
end
