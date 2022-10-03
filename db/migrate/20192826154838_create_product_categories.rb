class CreateProductCategories < ActiveRecord::Migration[5.0]
  def change
    create_table :product_categories do |t|
      t.string :code
      t.string :title
      t.string :comment
      t.timestamps
    end
  end
end
