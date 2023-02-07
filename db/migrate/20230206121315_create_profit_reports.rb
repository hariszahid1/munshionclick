class CreateProfitReports < ActiveRecord::Migration[6.1]
  def change
    create_table :profit_reports do |t|
      t.datetime :sale_from
      t.datetime :sale_to
      t.datetime :purchase_from
      t.datetime :purchase_to
      t.datetime :expense_from
      t.datetime :expense_to
      t.datetime :investment_from
      t.datetime :investment_to
      t.datetime :loan_from
      t.datetime :loan_to
      t.float :total_sale
      t.float :total_purchase
      t.float :total_expense
      t.float :total_loan_credit
      t.float :total_loan_debit
      t.float :total_investment_credit
      t.float :total_investment_debit
      t.float :miscellaneous_amount
      t.text :comment

      t.timestamps
    end
  end
end
