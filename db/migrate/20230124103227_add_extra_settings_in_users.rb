class AddExtraSettingsInUsers < ActiveRecord::Migration[6.1]
  def change
    add_column :users, :extra_settings, :json, if_not_exists: true
  end
end
