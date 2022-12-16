# frozen_string_literal: true

# ExpenseVouchers Controller
class ExpenseVouchersController < ApplicationController
  before_action :new_edit_index, only: %i[new show index edit create]
  before_action :set_expense_voucher, only: %i[show edit update destroy]
  include PdfCsvGeneralMethod
  include ExpenseVouchersHelper

  # GET /expense_vouchers
  # GET /expense_vouchers.json
  def index
    @q = ExpenseVoucher.ransack(params[:q])
    download_expenses_pdf_file if params[:pdf].present?
    download_expenses_csv_file if params[:csv].present?
    @expense_vouchers = @q.result.page(params[:page])
  end

  # GET /expense_vouchers/1
  # GET /expexpense_vouchersenses/1.json
  def show
    respond_to do |format|
      format.js
    end
  end

  # GET /expense_vouchers/new
  def new
    @expense_voucher = ExpenseVoucher.new
    @expense_voucher.expense_entry_vouchers.build
  end

  # GET /expense_vouchers/1/edit
  def edit; end

  # POST /expense_vouchers
  # POST /expense_vouchers.json
  def create
    @expense_voucher = ExpenseVoucher.new(expense_voucher_params)
    respond_to do |format|
      if @expense_voucher.save
        format.html { redirect_to expense_vouchers_path, notice: 'Expense Voucher was successfully created.' }
        format.json { render :show, status: :created, location: @expense }
      else
        format.html { render :new }
        format.json { render json: @expense.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /expense_vouchers/1
  # PATCH/PUT /expense_vouchers/1.json
  def update
    respond_to do |format|
      if @expense_voucher.update(expense_voucher_params)
        format.html { redirect_to expense_vouchers_path, notice: 'Expense Voucher was successfully updated.' }
        format.json { render :show, status: :ok, location: @expense }
      else
        format.html { render :edit }
        format.json { render json: @expense.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /expense_vouchers/1
  # DELETE /expense_vouchers/1.json
  def destroy
    @expense_voucher.destroy
    respond_to do |format|
      format.html { redirect_to expense_vouchers_path, notice: 'Expense Voucher was successfully Deleted.' }
      format.json { render :show, status: :ok, location: @expense }
    end
  end

  private

  # Use callbacks to share common setup or constraints between actions.
  def set_expense_voucher
    @expense_voucher = ExpenseVoucher.find(params[:id])
  end

  # Never trust parameters from the scary internet, only allow the white list through.
  def expense_voucher_params
    params.require(:expense_voucher).permit(:expense, :comment, :expense_type_id, :created_at,
                                            expense_entry_vouchers_attributes: %i[id expense_id amount comment
                                                                                  status expense_type_id _destroy])
  end

  def download_expenses_csv_file
    @sys_user = params[:export].present? ? SysUser.all : @q.result
    header_for_csv = %w[Id Expense_type Expense Remarks Comments Created_at]
    data_for_csv = get_data_for_expense_vouchers_csv
    generate_csv(data_for_csv, header_for_csv, 'ExpenseVoucher')
  end

  def download_expenses_pdf_file
    sorted_data
    generate_pdf(@sorted_data.as_json, 'Exense Voucher', 'pdf.html', 'A4', false, 'expense_vouchers/index.pdf.erb')
  end

  def new_edit_index
    @expense_types = ExpenseType.all
    @accounts = Account.all
  end
end
