class QrLinkToPosSetting < ActiveRecord::Migration[6.1]
  def change
    add_column :pos_settings, :qr_links, :json
  end
end
