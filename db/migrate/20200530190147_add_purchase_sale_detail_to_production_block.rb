class AddPurchaseSaleDetailToProductionBlock < ActiveRecord::Migration[5.2]
  def change
    add_reference :production_blocks, :purchase_sale_detail
    add_column :production_cycles, :quantity, :float
    add_column :production_cycles, :total_cost, :float
    add_column :production_cycles, :measurement_quantity, :float
    add_column :products, :measurement_quantity, :float
    add_column :items, :measurement_quantity, :float
  end
end
 
