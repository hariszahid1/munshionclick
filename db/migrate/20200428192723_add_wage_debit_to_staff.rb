class AddWageDebitToStaff < ActiveRecord::Migration[5.2]
  def change
    add_column :staffs, :wage_debit, :float
  end
end
