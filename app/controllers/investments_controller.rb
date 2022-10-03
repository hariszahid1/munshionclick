 class InvestmentsController < ApplicationController
  before_action :set_investment, only: [:show, :edit, :update, :destroy]

  # GET /investments
  # GET /investments.json
  def index
    @q = Investment.ransack(params[:q])
    if @q.result.count > 0
      @q.sorts = 'id desc' if @q.sorts.empty?
    end
    @investments = @q.result(distinct: true).page(params[:page])
    @investment = @q.result(distinct: true)
    @total_investment=@investment.pluck('Sum(invest)')
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
        format.js
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

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_investment
      @investment = Investment.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def investment_params
      params.require(:investment).permit(:invest,  :account_id, :comment, :created_at)
    end
end
