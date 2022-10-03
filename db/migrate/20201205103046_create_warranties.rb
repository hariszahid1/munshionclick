class CreateWarranties < ActiveRecord::Migration[5.2]
  def change
    create_table :warranties do |t|
      t.text :serial_number
      t.text :comment
      t.references :product

      t.timestamps
    end
  end
end
