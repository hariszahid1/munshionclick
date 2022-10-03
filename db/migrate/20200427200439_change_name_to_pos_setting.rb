class ChangeNameToPosSetting < ActiveRecord::Migration[5.2]
  def change
    rename_column :pos_settings, :type, :sys_type
  end
end
