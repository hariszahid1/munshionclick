class ExpensesController < ApplicationController
	before_action :check_access
  before_action :set_expense, only: [:show, :edit, :update, :destroy]

  # GET /expenses
  # GET /expenses.json
  def index
    @expense_types = ExpenseType.all
    @accounts=Account.all
    @start_date = DateTime.current.beginning_of_month
    @end_date = DateTime.now
    @expense_type = @expense_types
    @account=@accounts
    if params[:q].present?
      @expense_type = params[:q][:expense_entries_expense_type_id_eq] if params[:q][:expense_entries_expense_type_id_eq].present?
      @account = params[:q][:expense_entries_account_id_eq] if params[:q][:expense_entries_account_id_eq].present?
      @start_date = params[:q][:created_at_gteq] if params[:q][:created_at_gteq].present?
      @end_date = params[:q][:created_at_lteq] if params[:q][:created_at_lteq].present?
      params[:q][:created_at_lteq] = params[:q][:created_at_lteq].to_date.end_of_day if params[:q][:created_at_lteq].present?
      @q = Expense.ransack(params[:q])
    else
      @q = Expense.where(created_at: @start_date.to_date.beginning_of_day..@end_date.to_date.end_of_day).ransack(params[:q])
    end
    if @q.result.count > 0
      @q.sorts = 'id desc' if @q.sorts.empty?
    end
    @expenses = @q.result.page(params[:page])
    @expense_payment = Expense.joins(expense_entries: :payment).where('expenses.id':@expenses.pluck(:id)).group(:id).sum(:debit)
    @expense_payment_total = Expense.joins(expense_entries: :payment).where('expenses.id':@expenses.pluck(:id)).sum(:debit)

    @expense_total = ExpenseEntry.where(expense_type_id: @expense_type,account_id: @account, created_at: @start_date.to_date.beginning_of_day..@end_date.to_date.end_of_day).sum(:amount)
    if params[:submit_pdf_a4].present?
      if @q.result.count > 0
        @q.sorts = 'id desc' if @q.sorts.empty?
      end
      @expenses = @q.result
      request.format = 'pdf'
      print_pdf('Expenses From -'+@start_date.to_s+' to '+@end_date.to_s,'pdf.html','A4')
    end
    if params[:email].present?
      @pos_setting=PosSetting.first
      @expenses = @q.result
      @pdf_index=render_to_string(:pdf => "General Expenses",:template => 'expenses/index.pdf.erb',:filename => 'General Expenses')
    end
    if params[:submit_pdf_a8].present?
      if @q.result.count > 0
        @q.sorts = 'id desc' if @q.sorts.empty?
      end
      @expenses = @q.result
      request.format = 'pdf'
      print_pdf('Expenses From -'+@start_date.to_s+' to '+@end_date.to_s,'pdf.html','A8',true)
    end

    if params[:email].present?
      @pos_setting=PosSetting.first
      subject = "#{@pos_setting.display_name} - General Expenses"
      email = current_user.superAdmin.email_to.present? ? current_user.superAdmin.email_to : "info@munshionclick.com"
      pdf=[[@pdf_index,'General_Expenses']]
      ReportMailer.new_report_email(pdf,subject,email,"").deliver
      return redirect_to expenses_path
    end

  end

  # GET /expenses/1
  # GET /expenses/1.json
  def show
    respond_to do |format|
      format.js
    end
  end

  # GET /expenses/new
  def new
    @expense = Expense.new
    @expense.expense_entries.build
    @expense_types = ExpenseType.all
    @accounts=Account.all
    @account=current_user.user_account
  end

  # GET /expenses/1/edit
  def edit
    @expense_types = ExpenseType.all
    @accounts=Account.all
  end

  # POST /expenses
  # POST /expenses.json
  def create
    @expense = Expense.new(expense_params)
    @expense_types = ExpenseType.all
    @accounts=Account.all

    respond_to do |format|
      if @expense.save
        format.html { redirect_to expenses_path, notice: 'Expense was successfully created.' }
        format.json { render :show, status: :created, location: @expense }
      else
        format.html { render :new }
        format.json { render json: @expense.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /expenses/1
  # PATCH/PUT /expenses/1.json
  def update
    respond_to do |format|
      if @expense.update(expense_params)
        accounts = @expense&.expense_entries&.pluck(:account_id)
        accounts.each do |account|
          AccountPaymentJob.perform_later(current_user.superAdmin.company_type,account)
        end
        format.html { redirect_to expenses_path, notice: 'Expense was successfully updated.' }
        format.json { render :show, status: :ok, location: @expense }
      else
        format.html { render :edit }
        format.json { render json: @expense.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /expenses/1
  # DELETE /expenses/1.json
  def destroy
    accounts = @expense&.expense_entries&.pluck(:account_id)
    @expense.destroy
    accounts.each do |account|
      AccountPaymentJob.perform_later(current_user.superAdmin.company_type,account)
    end

    respond_to do |format|
      format.html { redirect_to expenses_path, notice: 'Expense was successfully Deleted.' }
      format.json { render :show, status: :ok, location: @expense }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_expense
      @expense = Expense.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def expense_params
      params.require(:expense).permit(:expense_type, :expense, :account_id, :comment, :expense_type_id,:created_at,
      :expense_entries_attributes => [:id, :expense_id, :amount, :comment,:status, :account_id, :expense_type_id,:_destroy])
    end
end
