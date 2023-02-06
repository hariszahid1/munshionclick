module ProfitReportsHelper
  def save_data_create
    data = []
    data.push(total_sale: PurchaseSaleItem.where(created_at:
      @profit_report.sale_from.beginning_of_day..@profit_report.sale_to.end_of_day).sum(:total_sale_price),
              total_purchase: PurchaseSaleItem.where(created_at:
      @profit_report.purchase_from.beginning_of_day..@profit_report.purchase_to.end_of_day).sum(:total_cost_price),
              total_expense: Expense.where(created_at:
      @profit_report.expense_from.beginning_of_day..@profit_report.expense_to.end_of_day).sum(:expense),
              invest_debit: Investment.where(created_at:
      @profit_report.investment_from.beginning_of_day..@profit_report.investment_to.end_of_day).sum(:debit),
              invest_credit: Investment.where(created_at:
      @profit_report.investment_from.beginning_of_day..@profit_report.investment_to.end_of_day).sum(:credit),
              loan_debit: Loan.where(created_at:
      @profit_report.loan_from.beginning_of_day..@profit_report.loan_to.end_of_day).sum(:debit),
              loan_credit: Loan.where(created_at:
        @profit_report.loan_from.beginning_of_day..@profit_report.loan_to.end_of_day).sum(:credit))

    @profit_report.update(total_sale: data.first[:total_sale], total_purchase: data.first[:total_purchase],
                          total_expense: data.first[:total_expense], total_loan_debit: data.first[:loan_debit],
                          total_loan_credit: data.first[:loan_credit],
                          total_investment_credit: data.first[:invest_credit],
                          total_investment_debit: data.first[:invest_debit])
  end


  def report_calculation
    @data = []
    @profit_reports.each do |report|
      @data.push(total_sale: PurchaseSaleItem.where(created_at:
        report.sale_from.beginning_of_day..report.sale_to.end_of_day).sum(:total_sale_price),
                 total_purchase: PurchaseSaleItem.where(created_at:
        report.purchase_from.beginning_of_day..report.purchase_to.end_of_day).sum(:total_cost_price),
                 total_expense: Expense.where(created_at:
        report.expense_from.beginning_of_day..report.expense_to.end_of_day).sum(:expense),
                 invest_debit: Investment.where(created_at:
        report.investment_from.beginning_of_day..report.investment_to.end_of_day).sum(:debit),
                 invest_credit: Investment.where(created_at:
        report.investment_from.beginning_of_day..report.investment_to.end_of_day).sum(:credit),
                 loan_debit: Loan.where(created_at:
        report.loan_from.beginning_of_day..report.loan_to.end_of_day).sum(:debit),
                 loan_credit: Loan.where(created_at:
          report.loan_from.beginning_of_day..report.loan_to.end_of_day).sum(:credit))
    end
  end
end
