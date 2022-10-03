class AddBhariProductionBlockToProductionBlock < ActiveRecord::Migration[5.2]
  def change
    add_column :production_blocks, :bhari_production_block_id, :integer
    add_column :production_blocks, :jalai_a, :integer
    add_column :production_blocks, :jalai_b, :integer
    add_column :production_blocks, :production_status, :integer
  end
end
