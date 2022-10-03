class AddColumnsToUsers < ActiveRecord::Migration[5.0]
  def change
    add_column :users, :name, :string
    add_column :users, :user_name, :string
    add_column :users, :father_name, :string
    add_column :users, :city, :string
    add_column :users, :phone, :string
    add_column :users, :fax, :string
    add_column :users, :address, :text
    add_column :users, :created_by_id, :integer
    add_index :users, :user_name, unique: true
  end
end
