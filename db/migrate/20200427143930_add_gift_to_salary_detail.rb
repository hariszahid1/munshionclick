class AddGiftToSalaryDetail < ActiveRecord::Migration[5.2]
  def change
    add_column :salary_details, :gift_pay, :float
    add_column :salary_details, :coverge_pay, :float
  end
end
