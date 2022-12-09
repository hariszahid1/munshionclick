class RenameColumnsOfInvestment < ActiveRecord::Migration[6.1]
  def change
		add_column :investments, :credit, :decimal

		rename_column :investments, :invest, :debit
		change_column :investments, :debit, :decimal
  end
end
