class ExpenseEntriesController < ApplicationController
  before_action :check_access
  before_action :set_expense_entry, only: [:show, :edit, :update, :destroy]

  # GET /expense_entries
  # GET /expense_entries.json
  def index
    @expense_types = ExpenseType.all
    @accounts=Account.all
    @start_date = DateTime.current.beginning_of_month
    @end_date = DateTime.now
    @expense_type = @expense_types
    @account=@accounts

    if params[:q].present?
      @expense_type = params[:q][:expense_type_id_eq] if params[:q][:expense_type_id_eq].present?
      @account = params[:q][:account_id_eq] if params[:q][:account_id_eq].present?
      @start_date = params[:q][:created_at_gteq] if params[:q][:created_at_gteq].present?
      @end_date = params[:q][:created_at_lteq] if params[:q][:created_at_lteq].present?
      params[:q][:created_at_lteq] = params[:q][:created_at_lteq].to_date.end_of_day if params[:q][:created_at_lteq].present?
      @q = ExpenseEntry.ransack(params[:q])
    else
      @q = ExpenseEntry.where(created_at: @start_date.to_date.beginning_of_day..@end_date.to_date.end_of_day).ransack(params[:q])
    end
    if @q.result.count > 0
      @q.sorts = 'id desc' if @q.sorts.empty?
    end
    @expense_entries = @q.result.page(params[:page])

    @expense_payment = ExpenseEntry.joins(:payment).where('expense_entries.id':@expense_entries.pluck(:id)).group(:id).sum(:debit)
    @expense_payment_total = ExpenseEntry.joins(:payment).where('expense_entries.id':@expense_entries.pluck(:id)).sum(:debit)

    @expense_total = ExpenseEntry.where(expense_type_id: @expense_type,account_id: @account, created_at: @start_date.to_date.beginning_of_day..@end_date.to_date.end_of_day).sum(:amount)
    if params[:submit_pdf_a4].present?
      if @q.result.count > 0
        @q.sorts = 'id desc' if @q.sorts.empty?
      end
      @expense_entries = @q.result
      request.format = 'pdf'
      respond_to do |format|
        format.html
        format.pdf do
          @pos_setting=PosSetting.first
          render pdf: "Day-Out",
          layout: 'pdf.html',
          page_size: 'A4',
          margin_top: '0',
          margin_right: '0',
          margin_bottom: '0',
          margin_left: '0',
          encoding: "UTF-8",
          footer:  {             # optional, use 'pdf_plain' for a pdf_plain.html.pdf.erb file, defaults to main layout
            right: '[page] of [topage]'},
          show_as_html: false
        end
      end
    end
    if params[:submit_pdf_a8].present?
      if @q.result.count > 0
        @q.sorts = 'id desc' if @q.sorts.empty?
      end
      @expense_entries = @q.result
      request.format = 'pdf'
      respond_to do |format|
        format.html
        format.pdf do
          @pos_setting=PosSetting.first
          render pdf: "Day-Out",
          layout: 'pdf.html',
          page_size: 'A8',
          margin_top: '0',
          margin_right: '0',
          margin_bottom: '0',
          margin_left: '0',
          encoding: "UTF-8",
          show_as_html: true
        end
      end
    end
  end

  # GET /expense_entries/1
  # GET /expense_entries/1.json
  def show
  end

  # GET /expense_entries/new
  def new
    @account=current_user.user_account
    @expense_entry = ExpenseEntry.new
  end

  # GET /expense_entries/1/edit
  def edit
  end

  # POST /expense_entries
  # POST /expense_entries.json
  def create
    @expense_entry = ExpenseEntry.new(expense_entry_params)

    respond_to do |format|
      if @expense_entry.save
        format.html { redirect_to @expense_entry, notice: 'Expense entry was successfully created.' }
        format.json { render :show, status: :created, location: @expense_entry }
      else
        format.html { render :new }
        format.json { render json: @expense_entry.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /expense_entries/1
  # PATCH/PUT /expense_entries/1.json
  def update
    respond_to do |format|
      if @expense_entry.update(expense_entry_params)
        AccountPaymentJob.perform_later(current_user.superAdmin.company_type,@expense_entry.account_id)
        format.html { redirect_to @expense_entry, notice: 'Expense entry was successfully updated.' }
        format.json { render :show, status: :ok, location: @expense_entry }
      else
        format.html { render :edit }
        format.json { render json: @expense_entry.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /expense_entries/1
  # DELETE /expense_entries/1.json
  def destroy
    @expense_entry.destroy
    AccountPaymentJob.perform_later(current_user.superAdmin.company_type,@expense_entry.account_id)
    respond_to do |format|
      format.html { redirect_to expense_entries_url, notice: 'Expense entry was successfully destroyed.' }
      format.json { head :no_content }
      format.js   { render :layout => false }
    end
  end

  def view_history
    @start_date = Date.today.beginning_of_month
    @end_date =  Date.today.end_of_month
    if params[:q].present?
      @start_date = params[:q][:created_at_gteq] if params[:q][:created_at_gteq].present?
      @end_date = params[:q][:created_at_lteq] if params[:q][:created_at_lteq].present?
      @item_id = params[:q][:item_id_eq] if params[:q][:item_id_eq].present?
      params[:q][:created_at_lteq] = params[:q][:created_at_lteq].to_date.end_of_day if params[:q][:created_at_lteq].present?
    end
    @event = %w[create update destroy]
    @q = PaperTrail::Version.where(item_type:"ExpenseEntry").order('created_at desc').ransack(params[:q])
    @expense_logs = @q.result.page(params[:page])
    respond_to do |format|
      format.js
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_expense_entry
      @expense_entry = ExpenseEntry.find(params[:id])
    end

    # Only allow a list of trusted parameters through.
    def expense_entry_params
      params.require(:expense_entry).permit(:amount, :expense_id, :expense_type_id, :account_id, :comment, :status)
    end
end
