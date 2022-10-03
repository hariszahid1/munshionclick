class AddExtraExpenceToPurchaseSaleItem < ActiveRecord::Migration[5.2]
  def change
    add_column :purchase_sale_items, :extra_expence, :float
  end
end
