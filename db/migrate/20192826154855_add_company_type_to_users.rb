class AddCompanyTypeToUsers < ActiveRecord::Migration[5.0]
  def change
    add_column :users, :company_type, :string, default: nil
  end
end
