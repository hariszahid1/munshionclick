class CreateProductionBlockTypes < ActiveRecord::Migration[5.2]
  def change
    create_table :production_block_types do |t|
      t.string :title
      t.integer :quantity
      t.integer :status
      t.text :comment
      t.timestamps
    end
  end
end
