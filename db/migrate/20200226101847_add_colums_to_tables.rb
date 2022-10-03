class AddColumsToTables < ActiveRecord::Migration[5.0]
  def change
    add_column :staffs, :wage_rate, :float, default: 0
    add_column :salaries, :comment, :text
    add_column :accounts, :comment, :text
    add_column :staffs, :comment, :text
    add_column :staffs, :balance, :float, default: 0
  end
end
