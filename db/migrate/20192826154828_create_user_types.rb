class CreateUserTypes < ActiveRecord::Migration[5.0]
  def change
    create_table :user_types do |t|
      t.string :title
      t.string :code
      t.float :discount_by_percentage
      t.float :discount_by_amount
      t.string :comment

      t.timestamps
    end
  end
end
