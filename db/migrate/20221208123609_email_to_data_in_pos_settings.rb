class EmailToDataInPosSettings < ActiveRecord::Migration[6.1]
  def change
    @pos_setting = PosSetting.last
    @pos_setting.update(email_to: 'abbasanwar158@gmail.com,abaid.ullah@devbox.co', email_cc: 'abbas.anwar@devbox.com') if @pos_setting.present?
  end
end
