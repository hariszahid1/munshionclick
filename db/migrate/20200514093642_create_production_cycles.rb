class CreateProductionCycles < ActiveRecord::Migration[5.2]
  def change
    create_table :production_cycles do |t|
      t.date :start_date
      t.date :end_date
      t.integer :status
      t.text :comment
      t.integer :cycle_type

      t.timestamps
    end
  end
end
