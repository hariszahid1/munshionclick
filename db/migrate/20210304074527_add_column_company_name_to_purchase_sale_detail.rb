class AddColumnCompanyNameToPurchaseSaleDetail < ActiveRecord::Migration[5.2]
  def change
    add_column :purchase_sale_details, :company_name, :string
  end
end
