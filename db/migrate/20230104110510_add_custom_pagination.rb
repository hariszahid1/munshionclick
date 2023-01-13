class AddCustomPagination < ActiveRecord::Migration[6.1]
  def change
    add_column :pos_settings, :custom_pagination, :json
  end
end
