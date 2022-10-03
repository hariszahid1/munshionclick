class HeaderFooterPlacement < ActiveRecord::Migration[5.2]
  def change
    add_column :pos_settings, :header, :boolean, default:true
    add_column :pos_settings, :footer, :boolean, default:true
    add_column :pos_settings, :header_logo_placement, :string, default: 'logo_disable_text_center'
    add_column :pos_settings, :footer_address_placement, :string, default: 'center'
    add_column :pos_settings, :logo_hieght, :string, default: '200'
    add_column :pos_settings, :logo_width, :string, default: '200'
    add_column :pos_settings, :header_hieght, :string, default: '50'
    rename_column :pos_settings, :purchase_sale_detail_show_margin_top, :pdf_margin_top
    rename_column :pos_settings, :purchase_sale_detail_show_margin_right, :pdf_margin_right
    rename_column :pos_settings, :purchase_sale_detail_show_margin_bottom, :pdf_margin_bottom
    rename_column :pos_settings, :purchase_sale_detail_show_margin_left, :pdf_margin_left
    add_column :pos_settings, :multi_language, :boolean, default: false
  end
end
