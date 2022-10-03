class AddPathraRemaningToSalarydetail < ActiveRecord::Migration[5.2]
  def change
    add_column :salary_details, :pather_remaning_quanity, :integer
    add_column :salary_details, :pather_salary_detail_id, :integer
  end
end
