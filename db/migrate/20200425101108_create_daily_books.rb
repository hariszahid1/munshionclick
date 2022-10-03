class CreateDailyBooks < ActiveRecord::Migration[5.2]
  def change
    create_table :daily_books do |t|
      t.datetime :book_date
      t.float :total_paid
      t.float :total_remaining
      t.references :department
      t.text :comment
      t.timestamps
    end
  end
end
