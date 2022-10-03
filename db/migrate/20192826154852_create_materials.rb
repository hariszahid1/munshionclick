class CreateMaterials < ActiveRecord::Migration[5.0]
  def change
    create_table :materials do |t|
      t.references :production, foreign_key: true
      t.references :item, foreign_key: true
      t.references :product, foreign_key: true
      t.decimal :cost_price
      t.decimal :sale_price
      t.decimal :total_cost_price
      t.decimal :total_sale_price
      t.decimal :quantity
      t.string :comment
      t.integer :status

      t.timestamps
    end
  end
end
