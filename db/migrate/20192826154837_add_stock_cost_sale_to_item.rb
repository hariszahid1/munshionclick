class AddStockCostSaleToItem < ActiveRecord::Migration[5.0]
  def change
    add_column :items, :stock, :float
    add_column :items, :cost, :float
    add_column :items, :sale, :float
    add_column :items, :location, :string
    change_column :purchase_sale_details, :total_bill, :float
    change_column :purchase_sale_details, :amount, :float
    change_column :purchase_sale_details, :discount_price, :float
    change_column :purchase_sale_items, :quantity, :float
    change_column :purchase_sale_items, :cost_price, :float
    change_column :purchase_sale_items, :sale_price, :float
    change_column :purchase_sale_items, :total_cost_price, :float
    change_column :purchase_sale_items, :total_sale_price, :float
    change_column :expenses, :expense, :float
  end
end
