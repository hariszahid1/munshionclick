class AddLocationToSalaryDetail < ActiveRecord::Migration[5.2]
  def change
    add_column :salary_details, :transaction_location, :integer
  end

end
