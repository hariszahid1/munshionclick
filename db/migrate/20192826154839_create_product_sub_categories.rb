class CreateProductSubCategories < ActiveRecord::Migration[5.0]
  def change
    create_table :product_sub_categories do |t|
      t.references :product_category, foreign_key: true
      t.string :code
      t.string :title
      t.string :comment

      t.timestamps
    end
  end
end
