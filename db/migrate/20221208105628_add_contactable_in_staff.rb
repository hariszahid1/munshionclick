class AddContactableInStaff < ActiveRecord::Migration[6.1]
  def change
    add_column :contacts, :contactable_id, :integer, polymorphic: true, if_not_exists: true
    add_column :contacts, :contactable_type, :string, polymorphic: true, if_not_exists: true
  end
end
