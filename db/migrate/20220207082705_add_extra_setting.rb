class AddExtraSetting < ActiveRecord::Migration[6.1]
  def change
    add_column :pos_settings, :extra_settings, :json
  end
end
