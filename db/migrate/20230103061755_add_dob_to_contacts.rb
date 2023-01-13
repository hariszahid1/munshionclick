class AddDobToContacts < ActiveRecord::Migration[6.1]
  def change
    add_column :contacts, :date_of_birth, :date
  end
end
