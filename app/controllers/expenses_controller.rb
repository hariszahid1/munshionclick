class ExpensesController < ApplicationController
  before_action :check_access
  before_action :set_expense, only: %i[show edit update destroy]
  include PdfCsvGeneralMethod
  include ExpensesHelper

  # GET /expenses
  # GET /expenses.json
  def index
    @expense_types = ExpenseType.all
    @accounts = Account.all
    @start_date = DateTime.current.beginning_of_month
    @end_date = DateTime.now
    @expense_type = @expense_types
    @account = @accounts
    if params[:q].present?
      if params[:q][:expense_entries_expense_type_id_eq].present?
        @expense_type = params[:q][:expense_entries_expense_type_id_eq]
      end
      @account = params[:q][:expense_entries_account_id_eq] if params[:q][:expense_entries_account_id_eq].present?
      @start_date = params[:q][:created_at_gteq] if params[:q][:created_at_gteq].present?
      @end_date = params[:q][:created_at_lteq] if params[:q][:created_at_lteq].present?
      if params[:q][:created_at_lteq].present?
        params[:q][:created_at_lteq] =
          params[:q][:created_at_lteq].to_date.end_of_day
      end
      @q = Expense.order('id desc').ransack(params[:q])
    else
      @q = Expense.order('id desc').where(created_at: @start_date.to_date.beginning_of_day..@end_date.to_date.end_of_day).ransack(params[:q])
    end
    @expenses = @q.result.page(params[:page])
    @expense_payment = Expense.joins(expense_entries: :payment).where('expenses.id': @expenses.pluck(:id)).group(:id).sum(:debit)
    @expense_payment_total = Expense.joins(expense_entries: :payment).where('expenses.id': @expenses.pluck(:id)).sum(:debit)

    @expense_total = ExpenseEntry.where(expense_type_id: @expense_type, account_id: @account,
                                        created_at: @start_date.to_date.beginning_of_day..@end_date.to_date.end_of_day).sum(:amount)

    if params[:submit_pdf_a8].present? || params[:submit_pdf_a4].present?
      @pdf_page_size = 'A4'
      @html_pdf = false
      if params[:submit_pdf_a8].present?
        @html_pdf = true
        @pdf_page_size = 'A8'
      end
      download_expenses_pdf_file
    end
    download_expenses_csv_file if params[:csv].present?
    send_email_file if params[:email].present?
    export_file if params[:export_data].present?

    
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
    @accounts = Account.all
    @account = current_user.user_account
  end

  # GET /expenses/1/edit
  def edit
    @expense_types = ExpenseType.all
    @accounts = Account.all
  end

  # POST /expenses
  # POST /expenses.json
  def create
    @expense = Expense.new(expense_params)
    @expense_types = ExpenseType.all
    @accounts = Account.all

    respond_to do |format|
      if @expense.save
        accounts = @expense&.expense_entries&.pluck(:account_id)
        accounts.each do |account|
          PaymentBalanceJob.set(wait: 1.minutes).perform_later(current_user.superAdmin.company_type)
        end
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
          AccountPaymentJob.perform_later(current_user.superAdmin.company_type, account)
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
      AccountPaymentJob.perform_later(current_user.superAdmin.company_type, account)
    end

    respond_to do |format|
      format.html { redirect_to expenses_path, notice: 'Expense was successfully Deleted.' }
      format.json { render :show, status: :ok, location: @expense }
    end
  end

    def analytics
    type = params[:type]
    case type
    when 'weekly'
      date_limit = DateTime.current.all_week
    when 'monthly'
      date_limit = DateTime.current.all_month
    when 'yearly'
      date_limit = DateTime.current.all_year
    else
      date_limit = DateTime.current.all_day
    end

    @exp_date = []
    @exp_type = []
    @the_type = []
    @exp_types = {}
    @expenses_g = ExpenseEntry.joins(:expense_type).where(created_at: date_limit).group(:title, 'date(expense_entries.created_at)').sum(:amount)
    @expenses_d = ExpenseEntry.joins(:expense_type).where(created_at: date_limit).group('date(expense_entries.created_at)').sum(:amount)
    @expenses_t = ExpenseEntry.joins(:expense_type).where(created_at: date_limit).group(:title).sum(:amount)
		
    @expenses_g.each do |expense|
      @exp_type.push(expense.last.to_f.round(2).to_s)
    end
		@expenses_d.each do |expense|
      @exp_date.push(expense.first.to_s)
    end
		@expenses_t.each do |expense|
      @the_type.push(expense.first.to_s)
			exp = ExpenseEntry.joins(:expense_type).where(created_at: date_limit).where('expense_types.title': expense.first).group('date(expense_entries.created_at)').sum(:amount)
			array = []
			@exp_date.each do |date|
				exp.each do |e|
					if date.to_s == e.first.to_s
						array.push(e.last)
					else
						array.push(0)
					end
				end
			end
			@exp_types[expense.first] = array
    end
		@exp_date_join = @exp_date.join('&').to_s
		@the_type_join = @the_type.join('&').to_s

  end

  private

  # Use callbacks to share common setup or constraints between actions.
  def set_expense
    @expense = Expense.find(params[:id])
  end

  # Never trust parameters from the scary internet, only allow the white list through.
  def expense_params
    params.require(:expense).permit(:expense_type, :expense, :account_id, :comment, :expense_type_id, :created_at,
                                    expense_entries_attributes: %i[id expense_id amount comment status account_id expense_type_id _destroy])
  end

  def download_expenses_csv_file
    @expenses = @q.result
    header_for_csv = %w[id type_wise expense paid_by expense_remark comment date]
    data_for_csv = get_data_for_expenses_csv
    generate_csv(data_for_csv, header_for_csv,
                 "Expenses-Total-#{@expenses.count}-#{DateTime.now.strftime('%d-%m-%Y-%H-%M')}")
  end

  def download_expenses_pdf_file
    sort_data_according
    generate_pdf(@sorted_data.as_json, "Expenses-Total-#{@sorted_data.count}-#{DateTime.now.strftime('%d-%m-%Y-%H-%M')}",
                 'pdf.html', @pdf_page_size, @html_pdf, 'expenses/index.pdf.erb')
  end

  def send_email_file
    sort_data_according
    EmailJob.perform_later(@sorted_data.as_json, 'expenses/index.pdf.erb', params[:email_value],
                           params[:email_choice], params[:subject], params[:body],
                           current_user, "Expenses-Total-#{@sorted_data.count}-#{DateTime.now.strftime('%d-%m-%Y-%H-%M')}")
    flash[:notice] = if params[:email_value].present?
                       "Email has been sent to #{params[:email_value]}"
                     else
                       "Email has been sent to #{current_user.email}"
                     end
    redirect_to expenses_path
  end

  def sort_data_according
    @sorted_data = []
    @q.result.each do |d|
      @sorted_data << {
        id: d.id,
        type_wise: d.expense_entries.joins(:expense_type).group(:expense_type).sum(:amount).map do |d|
                     d.first.title.to_s + ':' + d.last.to_s
                   end,
        expense: d.expense.to_f.round(2),
        paid_by: Account.where(id: d.expense_entries.distinct.pluck(:account_id)).pluck(:title).to_s,
        expense_remark: d.comment,
        comment: d.expense_entries.distinct.pluck(:comment),
        date: d.created_at.strftime('%d%b%y') != d.updated_at.strftime('%d%b%y') ? d.updated_at.strftime('%d%b%y at %H:%M%p') : d.created_at.strftime('%d%b%y at %H:%M%p'),
        total: @expense_payment_total
      }
    end
  end

  def export_file
    export_data('Expense')
  end
end
