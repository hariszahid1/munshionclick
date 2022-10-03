class CreateSalaryDetailProductQuantities < ActiveRecord::Migration[5.2]
  def change
    create_table :salary_detail_product_quantities do |t|
      t.references :salary_detail
      t.references :staff
      t.references :product
      t.float :quantity

      t.timestamps
    end
  end
end
 
