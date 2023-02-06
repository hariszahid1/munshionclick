# frozen_string_literal: true

# Profit Reports Controller
class ProfitReportsController < ApplicationController
  before_action :check_access
  before_action :set_profit_report, only: %i[show edit update destroy]
  include ProfitReportsHelper

  # GET /profit_reports
  # GET /profit_reports.json
  def index
    @q = ProfitReport.ransack(params[:q])
    @profit_reports = @q.result
    report_calculation
  end

  # GET /profit_reports/new
  def new
    @profit_report = ProfitReport.new
  end

  # GET /profit_reports/1/edit
  def edit; end

  # POST /profit_reports
  # POST /profit_reports.json
  def create
    @profit_report = ProfitReport.new(profit_report_params)
    if @profit_report.save
      save_data_create
      redirect_to profit_reports_path, notice: 'Profit Report was successfully created.'
    else
      render :new
    end
  end

  def update
    respond_to do |format|
      if @profit_report.update(profit_report_params)
        format.html { redirect_to profit_reports_path, notice: 'Profit Report was successfully updated.' }
        format.json { render :show, status: :created, location: @profit_report }
      else
        format.html { render :new }
        format.json { render json: @profit_report.errors, status: :unprocessable_entity }
      end
    end
  end

  def destroy
    @profit_report.destroy
    respond_to do |format|
      format.html { redirect_to profit_reports_path, notice: 'Profit Report was successfully destroyed.' }
    end
  end

  private

  def set_profit_report
    @profit_report = ProfitReport.find(params[:id])
  end

  # Never trust parameters from the scary internet, only allow the white list through.
  def profit_report_params
    params.require(:profit_report).permit(:sale_from, :sale_to, :purchase_from, :purchase_to, :expense_from,
                                          :expense_to, :investment_from, :investment_to, :loan_from, :loan_to,
                                          :miscellaneous_amount, :comment)
  end

end
