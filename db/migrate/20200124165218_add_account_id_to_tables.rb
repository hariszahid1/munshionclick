class AddAccountIdToTables < ActiveRecord::Migration[5.0]
  def change
    add_reference :expenses, :account, foreign_key: true
    add_reference :investments, :account, foreign_key: true
    add_reference :purchase_sale_details, :account, foreign_key: true
  end
end
