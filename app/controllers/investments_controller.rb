 class InvestmentsController < ApplicationController
  before_action :check_access
  before_action :set_investment, only: [:show, :edit, :update, :destroy]
  
  # GET /investments
  # GET /investments.json
  def index
    @q = Investment.ransack(params[:q])
    if @q.result.count > 0
      @q.sorts = 'id desc' if @q.sorts.empty?
    end

    @options_for_select = Investment.all
    @custom_pagination = params[:limit].present? ? params[:limit] : 25
    @custom_pagination = @pos_setting.custom_pagination['investments'] if @pos_setting&.custom_pagination.present? && @pos_setting&.custom_pagination['investments'].present?
    @investments = @q.result(distinct: true).page(params[:page]).per(@custom_pagination)
    @investment = @q.result(distinct: true)
    @total_investment=@investment.pluck('Sum(debit)','Sum(credit)')
    @accounts=Account.all
    if params[:submit_pdf_staff_with].present?
      if @q.result.count > 0
        @q.sorts = 'created_at desc' if @q.sorts.empty?
      end
      @investments=@q.result(distinct: true)
      request.format = 'pdf'
      respond_to do |format|
        format.html
        format.pdf do
          render pdf: 'index_staff_wise',
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

    @dc_sum = []
    @dc_sum.push(Investment.sum(:debit))
    @dc_sum.push(Investment.sum(:credit))

    @dc_count = []
    @dc_count.push(Investment.count(:debit))
    @dc_count.push(Investment.count(:credit))

    @db_by_date = Investment.group('date(created_at)').sum(:debit)
    @cr_by_date = Investment.group('date(created_at)').sum(:credit)

    @db_keys = @db_by_date.keys
    @db_total = @db_by_date.values
    @cr_total = @cr_by_date.values

    @today_debit_investment = @q.result.where(created_at: Time.current.all_day).sum(:debit).to_f
    @today_credit_investment = @q.result.where(created_at: Time.current.all_day).sum(:credit).to_f
    @yesterday_debit_investment = @q.result.where(created_at: 1.day.ago.all_day).sum(:debit).to_f
    @yesterday_credit_investment = @q.result.where(created_at: 1.day.ago.all_day).sum(:credit).to_f
    @percentage_debit_investment = ((@today_debit_investment - @yesterday_debit_investment) / (@yesterday_debit_investment.to_f.positive? ? @yesterday_debit_investment.to_f : 1 ) ).round(2)
    @percentage_credit_investment = ((@today_credit_investment - @yesterday_credit_investment) / (@yesterday_credit_investment.to_f.positive? ? @yesterday_credit_investment.to_f : 1 ) ).round(2)
    @investment_debit_count = @q.result.where(created_at: Time.current.all_day).count(:debit)
    @investment_credit_count = @q.result.where(created_at: Time.current.all_day).count(:credit)
    @monthly_debit_investment = @q.result.where(created_at: Time.current.all_month).sum(:debit).to_f
    @monthly_credit_investment = @q.result.where(created_at: Time.current.all_month).sum(:credit).to_f


  end

  # GET /investments/1
  # GET /investments/1.json
  def show

  end

  # GET /investments/new
  def new
    @investment = Investment.new
    @accounts=Account.all
  end

  # GET /investments/1/edit
  def edit
    @accounts=Account.all
  end

  # POST /investments
  # POST /investments.json
  def create
    @investment = Investment.new(investment_params)
    respond_to do |format|
      if @investment.save
        PaymentBalanceJob.set(wait: 1.minutes).perform_later(current_user.superAdmin.company_type)
        format.html { redirect_to investments_path, notice: 'Investment was successfully created.' }
        format.json { render :show, status: :created, location: @investment }
      else
        format.html { render :new }
        format.json { render json: @investment.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /investments/1
  # PATCH/PUT /investments/1.json
  def update
    respond_to do |format|
      if @investment.update(investment_params)
        account = @investment.account
        AccountPaymentJob.perform_later(current_user.superAdmin.company_type,account.id)
        format.html { redirect_to investments_path, notice: 'Investment was successfully updated.' }
        format.json { render :show, status: :ok, location: @investment }
      else
        format.html { render :edit }
        format.json { render json: @investment.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /investments/1
  # DELETE /investments/1.json
  def destroy
    account = @investment.account
    @investment.destroy
    respond_to do |format|
      AccountPaymentJob.perform_later(current_user.superAdmin.company_type,account.id)
      format.html { redirect_to investments_url, notice: 'Investment was successfully destroyed.' }
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
    @q = PaperTrail::Version.where(item_type:"Investment").order('created_at desc').ransack(params[:q])
    @investment_logs = @q.result.page(params[:page])
    respond_to do |format|
      format.js
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_investment
      @investment = Investment.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def investment_params
      params.require(:investment).permit(:debit,  :account_id, :comment, :created_at, :credit)
    end
end
