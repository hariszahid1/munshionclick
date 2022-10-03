class AddExpiryDateToPos < ActiveRecord::Migration[5.2]
  def change
    add_column :pos_settings, :expiry_date, :datetime
    PosSetting.reset_column_information
    PosSetting.update_all('expiry_date=created_at')
    PosSetting.all.each do |pos|
      pos.update(expiry_date: pos.expiry_date+365.day)
    end
  end
end
