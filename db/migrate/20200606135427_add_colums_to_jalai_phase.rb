class AddColumsToJalaiPhase < ActiveRecord::Migration[5.2]
  def change
    add_column :production_cycles, :lines, :integer
    change_column :production_blocks, :jalai_a, :float
    change_column :production_blocks, :jalai_b, :float
  end
end
 
