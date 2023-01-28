class AddActiveInDepartments < ActiveRecord::Migration[6.1]
  def change
    add_column :departments, :active, :boolean, default: false, if_not_exists: true
  end
end
