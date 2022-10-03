class TitlePadding < ActiveRecord::Migration[5.2]
  def change
    add_column :pos_settings, :title_padding, :string, default: '10'
  end
end
