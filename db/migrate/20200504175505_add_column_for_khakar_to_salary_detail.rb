class AddColumnForKhakarToSalaryDetail < ActiveRecord::Migration[5.2]
  def change
    add_column :salary_details, :staff_pathera_id, :integer
  end
end
