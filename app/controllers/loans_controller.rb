# frozen_string_literal: true

# Loans Controller
class LoansController < ApplicationController
  before_action :check_access
  before_action :set_loan, only: %i[show edit update destroy]
  before_action :set_account, only: %i[new edit update index]
  include PdfCsvGeneralMethod
  include LoansHelper

  require 'tempfile'
  require 'csv'
  # GET /loans
  # GET /loans.json
  def index
    @q = Loan.ransack(params[:q])
    @total_loan = @q.result.pluck('Sum(debit)', 'Sum(credit)')
    
    @options_for_select = Loan.all
    @custom_pagination = params[:limit].present? ? params[:limit] : 25
    @starting_number = 1 + 25 * ([params[:page].to_i, 1].max - 1)
    @custom_pagination = @pos_setting.custom_pagination['loans'] if @pos_setting&.custom_pagination.present? && @pos_setting&.custom_pagination['loans'].present?
    @loans = @q.result(distinct: true).page(params[:page]).per(@custom_pagination)
    download_loans_pdf_file if params[:pdf].present?
    download_loans_csv_file if params[:csv].present?
    loans_credit_debit_report
    
  end

  # GET /loans/1
  # GET /loans/1.json
  def show; end

  # GET /loans/new
  def new
    @loan = Loan.new
  end

  # GET /loans/1/edit
  def edit; end

  # POST /loans
  # POST /loans.json
  def create
    @accounts = Account.all

    @loan = Loan.new(loan_params)
    respond_to do |format|
      if @loan.save
        PaymentBalanceJob.set(wait: 1.minutes).perform_later(current_user.superAdmin.company_type)
        format.html { redirect_to loans_path, notice: 'Loan was successfully created.' }
        format.json { render :show, status: :created, location: @loan }
      else
        format.html { render :new }
        format.json { render json: @loan.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /loans/1
  # PATCH/PUT /loans/1.json
  def update
    respond_to do |format|
      if @loan.update(loan_params)
        account = @loan.account
        AccountPaymentJob.perform_later(current_user.superAdmin.company_type, account.id)
        format.html { redirect_to loans_path, notice: 'Loan was successfully updated.' }
        format.json { render :show, status: :ok, location: @loan }
      else
        format.html { render :edit }
        format.json { render json: @loan.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /loans/1
  # DELETE /loans/1.json
  def destroy
    account = @loan.account
    @loan.destroy
    respond_to do |format|
      AccountPaymentJob.perform_later(current_user.superAdmin.company_type, account.id)
      format.html { redirect_to loans_path, notice: 'Loan was successfully destroyed.' }
      format.json { head :no_content }
      format.js   { render layout: false }
    end
  end

  def view_history
    @start_date = Date.today.beginning_of_month
    @end_date = Date.today.end_of_month
    if params[:q].present?
      @start_date = params[:q][:created_at_gteq] if params[:q][:created_at_gteq].present?
      @end_date = params[:q][:created_at_lteq] if params[:q][:created_at_lteq].present?
      @item_id = params[:q][:item_id_eq] if params[:q][:item_id_eq].present?
      if params[:q][:created_at_lteq].present?
        params[:q][:created_at_lteq] =
          params[:q][:created_at_lteq].to_date.end_of_day
      end
    end
    @event = %w[create update destroy]
    @q = PaperTrail::Version.where(item_type: 'Investment').order('created_at desc').ransack(params[:q])
    @loan_logs = @q.result.page(params[:page])
    respond_to do |format|
      format.js
    end
  end

  def loans_credit_debit_report
    @today_debit_loan = @q.result.where(created_at: Time.current.all_day).sum(:debit).to_f.round(2)
    @today_credit_loan = @q.result.where(created_at: Time.current.all_day).sum(:credit).to_f.round(2)
    @loan_debit_count = @q.result.where(created_at: Time.current.all_day).count(:debit)
    @loan_credit_count = @q.result.where(created_at: Time.current.all_day).count(:credit)
    @monthly_debit_loan = @q.result.where(created_at: Time.current.all_month).sum(:debit).to_f.round(2)
    @monthly_credit_loan = @q.result.where(created_at: Time.current.all_month).sum(:credit).to_f.round(2)
    @yearly_debit_loan = @q.result.where(created_at: Time.current.all_year).sum(:debit).to_f.round(2)
    @yearly_credit_loan = @q.result.where(created_at: Time.current.all_year).sum(:credit).to_f.round(2)
    @yearly_debit_count_loan = @q.result.where(created_at: Time.current.all_year).count(:debit)
    @yearly_credit_count_loan = @q.result.where(created_at: Time.current.all_year).count(:credit)
    @yearly_report_loan = @yearly_debit_loan + @yearly_credit_loan
  end

  private

  # Use callbacks to share common setup or constraints between actions.
  def set_loan
    @loan = Loan.find(params[:id])
  end

  # Never trust parameters from the scary internet, only allow the white list through.
  def loan_params
    params.require(:loan).permit(:debit, :credit, :account_id, :comment, :created_at)
  end

  def set_account
    @accounts = Account.all
  end

  def download_loans_pdf_file
    sorted_data
    generate_pdf(@sorted_data.as_json, 'Loans', 'pdf.html', 'A4', false, 'loans/index.pdf.erb')
  end

  def download_loans_csv_file
    header_for_csv = %w[Credit Debit Account Comment Created_at]
    data_for_csv = get_data_for_loans_csv
    generate_csv(data_for_csv, header_for_csv, 'Loan')
  end
end
