class AddProductToSalaryBook < ActiveRecord::Migration[5.0]
  def change
    add_reference :salary_details, :product
  end
end
