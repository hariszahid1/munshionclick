class AddTotalBricksToProductioncycle < ActiveRecord::Migration[5.2]
  def change
    add_column :production_cycles, :total_bricks, :float
  end
end
 
