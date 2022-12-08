class AddEmailColumnsToPosSettings < ActiveRecord::Migration[6.1]
  def change
    add_column :pos_settings, :email_to, :text
    add_column :pos_settings, :email_cc, :text
    add_column :pos_settings, :email_bcc, :text
  end
end
