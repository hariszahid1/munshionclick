class AddRawProductToSalaryDetail < ActiveRecord::Migration[5.2]
  def change
    add_reference :salary_details, :raw_product
  end
end
