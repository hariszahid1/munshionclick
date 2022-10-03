class AddStatusToSalaryDetail < ActiveRecord::Migration[5.0]
  def change
    add_column :salary_details, :status, :integer
    add_column :salary_details, :extra, :integer
  end
end
