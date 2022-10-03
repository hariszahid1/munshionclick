class AddItemAndPriceToProductionCycle < ActiveRecord::Migration[5.2]
  def change
    add_reference :production_cycles, :item
    add_column :production_cycles, :cost, :float
  end
end
 
