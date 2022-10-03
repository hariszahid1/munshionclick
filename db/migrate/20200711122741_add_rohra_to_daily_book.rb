class AddRohraToDailyBook < ActiveRecord::Migration[5.2]
  def change
    add_column :daily_books, :brick_rohra, :integer, default: 0 # nakasi stock
    add_column :daily_books, :tile_rohra, :integer, default: 0 # nakasi stock
  end
end
 
