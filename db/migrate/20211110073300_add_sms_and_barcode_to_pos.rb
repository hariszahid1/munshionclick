class AddSmsAndBarcodeToPos < ActiveRecord::Migration[5.2]
  def change
    add_column :pos_settings, :is_sms, :boolean, default:false
    add_column :pos_settings, :is_qr, :boolean, default:false
    add_column :pos_settings, :sms_user, :text
    add_column :pos_settings, :sms_pass, :text
    add_column :pos_settings, :sms_mask, :text
    add_column :pos_settings, :sms_templates, :json
  end
end
