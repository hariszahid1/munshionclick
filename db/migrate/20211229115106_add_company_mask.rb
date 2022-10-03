class AddCompanyMask < ActiveRecord::Migration[5.2]
  def change
    add_column :pos_settings, :company_mask, :string
  end
end
