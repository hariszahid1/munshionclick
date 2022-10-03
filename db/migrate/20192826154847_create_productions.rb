class CreateProductions < ActiveRecord::Migration[5.0]
  def change
    create_table :productions do |t|
      t.references :product, foreign_key: true
      t.decimal :operation_cost
      t.decimal :cost_price
      t.decimal :sale_price
      t.string :comment
      t.integer :status

      t.timestamps
    end
  end
end
