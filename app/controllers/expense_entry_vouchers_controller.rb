# frozen_string_literal: true

# ExpenseEntryVouchers Controller
class ExpenseEntryVouchersController < ApplicationController
  before_action :set_expense_entry_voucher, only: %i[show edit update destroy]
  before_action :set_expense_type, only: %i[show new edit create index]
  # GET /expense_entry_voucher
  # GET /expense_entries.json
  def index
    @q = ExpenseEntryVoucher.ransack(params[:q])
    @expense_entry_vouchers = @q.result.page(params[:page])
  end

  # GET /expense_entry_vouchers/1
  # GET /expense_entry_vouchers/1.json
  def show
  end

  # GET /expense_entry_vouchers/new
  def new
    @expense_entry = ExpenseEntry.new
  end

  # GET /expense_entry_vouchers/1/edit
  def edit; end

  # POST /expense_entry_vouchers
  # POST /expense_entry_vouchers.json
  def create
    @expense_entry_voucher = ExpenseEntryVoucher.new(expense_entry_params)
    respond_to do |format|
      if @expense_entry_voucher.save
        format.html { redirect_to @expense_entry_voucher, notice: 'Expense Entry Voucher was successfully created.' }
        format.json { render :show, status: :created, location: @expense_entry }
      else
        format.html { render :new }
        format.json { render json: @expense_entry_voucher.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /expense_entry_vouchers/1
  # PATCH/PUT /expense_entry_vouchers/1.json
  def update
    respond_to do |format|
      if @expense_entry_voucher.update(expense_entry_voucher_params)
        format.html { redirect_to expense_entry_vouchers_path, notice: 'Expense entry was successfully updated.' }
        format.json { render :show, status: :ok, location: @expense_entry_voucher }
      else
        format.html { render :edit }
        format.json { render json: @expense_entry_voucher.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /expense_entry_vouchers/1
  # DELETE /expense_entry_vouchers/1.json
  def destroy
    @expense_entry_voucher.destroy
    respond_to do |format|
      format.html { redirect_to expense_entry_voucher_url, notice: 'Expense entry Voucher was successfully destroyed.' }
      format.json { head :no_content }
      format.js   { render layout: false }
    end
  end

  private

  # Use callbacks to share common setup or constraints between actions.
  def set_expense_entry_voucher
    @expense_entry_voucher = ExpenseEntryVoucher.find(params[:id])
  end

  def set_expense_type
    @expense_types = ExpenseType.all
  end

  # Only allow a list of trusted parameters through.
  def expense_entry_voucher_params
    params.require(:expense_entry_voucher).permit(:amount, :expense_voucher_id, :expense_type_id, :comment, :status,
                                          :expenseable_type, :expenseable_id)
  end
end
