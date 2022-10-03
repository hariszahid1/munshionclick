class CreateDailySales < ActiveRecord::Migration[5.0]
  def change
    create_table :daily_sales do |t|
      t.decimal :sale
      t.decimal :cash_out
      t.integer :shift
      t.string :comment
      t.timestamps
    end
  end
end
