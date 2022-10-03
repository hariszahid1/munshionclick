class CreateProductWarranties < ActiveRecord::Migration[5.2]
  def change
    create_table :product_warranties do |t|
      t.references :purchase_sale_detail
      t.references :product
      t.text :serial

      t.timestamps
    end
  end
end
