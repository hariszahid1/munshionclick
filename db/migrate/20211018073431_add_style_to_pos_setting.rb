class AddStyleToPosSetting < ActiveRecord::Migration[5.2]
  def change
    add_column :pos_settings, :title_style,  :text
    add_column :pos_settings, :image_style,  :text
    add_column :pos_settings, :header_style, :text
    add_column :pos_settings, :footer_style, :text

  end
end
