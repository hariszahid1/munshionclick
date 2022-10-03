class AddColumnToDailyBook < ActiveRecord::Migration[5.2]
  def change
    add_column :daily_books, :wage_rate, :float, default: 0.00
    add_column :daily_books, :quantity, :float, default: 0.00
    add_column :daily_books, :amount, :float, default: 0.00
    add_column :daily_books, :status, :integer
    add_column :daily_books, :extra, :integer, default: 0.00
    add_column :daily_books, :coverge_rate, :float, default: 0.00
    add_column :daily_books, :wage_debit, :float, default: 0.00
  end
end
