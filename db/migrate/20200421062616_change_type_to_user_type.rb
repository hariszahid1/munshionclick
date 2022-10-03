class ChangeTypeToUserType < ActiveRecord::Migration[5.2]
  def change
    rename_column :staffs, :type, :staff_type
  end
end
