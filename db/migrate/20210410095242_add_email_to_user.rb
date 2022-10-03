class AddEmailToUser < ActiveRecord::Migration[5.2]
  def change
    add_column :users, :email_to, :text
    add_column :users, :email_cc, :text
    add_column :users, :email_bcc, :text
  end
end
