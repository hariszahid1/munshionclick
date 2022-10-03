class CreateStaffRawProducts < ActiveRecord::Migration[5.2]
  def change
    create_table :staff_raw_products do |t|
      t.references :staff
      t.references :raw_product

      t.timestamps
    end
  end
end
