class AddWebsiteToPosSetting < ActiveRecord::Migration[5.2]
  def change
    add_column :pos_settings, :website, :text
  end
end
