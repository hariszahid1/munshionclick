class AddAccountToPosSettings < ActiveRecord::Migration[5.2]
  def change
    add_reference :pos_settings, :account
  end
end
