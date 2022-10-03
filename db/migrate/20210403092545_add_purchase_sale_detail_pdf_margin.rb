class AddPurchaseSaleDetailPdfMargin < ActiveRecord::Migration[5.2]
  def change
    add_column :pos_settings, :purchase_sale_detail_show_margin_top, :integer,default:0
    add_column :pos_settings, :purchase_sale_detail_show_margin_right, :integer,default:0
    add_column :pos_settings, :purchase_sale_detail_show_margin_bottom, :integer,default:0
    add_column :pos_settings, :purchase_sale_detail_show_margin_left, :integer,default:0
    add_column :pos_settings, :purchase_sale_detail_show_page_size, :string, default: 'A4'
    add_column :pos_settings, :purchase_sale_detail_show_line_height, :integer, default: 20
  end
end
