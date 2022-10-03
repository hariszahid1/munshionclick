class AddCodeStatusToStaff < ActiveRecord::Migration[5.2]
  def change
    add_column :staffs, :code, :string
    add_column :staffs, :type, :integer
    rename_column :staffs, :department, :staff_department
  end
end
