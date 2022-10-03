class AddCostBricksToCycle < ActiveRecord::Migration[5.2]
  def change
    add_column :production_cycles, :cost_per_line, :float
    add_column :production_cycles, :per_product_cost, :float
    add_column :production_cycles, :per_thousand_product_cost, :float
    add_column :production_cycles, :item_quantity_per_line, :float
    add_column :production_cycles, :total_item_quantity, :float
    add_column :production_cycles, :per_ton_bricks, :float
  end
end
 
