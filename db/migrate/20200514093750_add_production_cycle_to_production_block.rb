class AddProductionCycleToProductionBlock < ActiveRecord::Migration[5.2]
  def change
    add_reference :production_blocks, :production_cycle
  end
end
