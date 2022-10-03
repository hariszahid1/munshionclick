class AddGstToPos < ActiveRecord::Migration[5.2]
  def change
    add_column :pos_settings, :gst, :text
    add_column :pos_settings, :ntn, :text
    add_column :sys_users, :gst, :text
    add_column :sys_users, :ntn, :text
  end
end
