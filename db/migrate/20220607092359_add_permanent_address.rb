class AddPermanentAddress < ActiveRecord::Migration[6.1]
  def change
    add_column :contacts, :permanent_address,  :text
  end
end
