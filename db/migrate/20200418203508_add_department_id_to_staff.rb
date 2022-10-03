class AddDepartmentIdToStaff < ActiveRecord::Migration[5.2]
  def change
    add_reference :staffs, :department
  end
end
