class AddTypeToPosSetting < ActiveRecord::Migration[5.0]
  def change
    add_column :pos_settings, :type, :integer
  end
end
