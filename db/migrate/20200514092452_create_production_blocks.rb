class CreateProductionBlocks < ActiveRecord::Migration[5.2]
  def change
    create_table :production_blocks do |t|
      t.references :production_block_type, foreign_key: true
      t.string :title
      t.integer :bricks_quantity
      t.integer :tiles_quantity
      t.date :date
      t.integer :status
      t.text :comment

      t.timestamps
    end
  end
end
