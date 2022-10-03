class CreatePropertyPlans < ActiveRecord::Migration[5.2]
  def change
    create_table :property_plans do |t|
      t.integer :property_type
      t.decimal :area_in_marla, precision: 7, scale: 2
      t.decimal :price_per_marla, precision: 15, scale: 2
      t.decimal :total_price, precision: 15, scale: 2
      t.integer :payment_type
      t.integer :payment_plan
      t.integer :no_of_installments
      t.decimal :advance, precision: 15, scale: 2
      t.integer :high_amount_installments
      t.decimal :total_high_amount, precision: 15, scale: 2

      t.timestamps
    end
  end
end
