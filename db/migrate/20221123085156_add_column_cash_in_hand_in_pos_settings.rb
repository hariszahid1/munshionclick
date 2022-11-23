class AddColumnCashInHandInPosSettings < ActiveRecord::Migration[6.1]
  def change
    add_column :pos_settings, :cash_in_hand, :decimal
    PosSetting.update(cash_in_hand: Account.sum(:amount))
  end
end
