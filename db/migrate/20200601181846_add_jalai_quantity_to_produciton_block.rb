class AddJalaiQuantityToProducitonBlock < ActiveRecord::Migration[5.2]
  def change
    add_column :production_blocks, :jalai_a_quantity, :float
    add_column :production_blocks, :jalai_b_quantity, :float

  end
end
 
