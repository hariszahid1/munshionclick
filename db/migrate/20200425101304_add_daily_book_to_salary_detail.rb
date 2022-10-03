class AddDailyBookToSalaryDetail < ActiveRecord::Migration[5.2]
  def change
    add_reference :salary_details, :daily_book
    # add_column :daily_books, :comment, :text
  end
end
