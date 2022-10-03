class AddLoadingAndUnloadingToPurchaseSaleDetail < ActiveRecord::Migration[5.0]
  def change
    add_column :purchase_sale_details, :loading, :float, default: 0
  end
end
