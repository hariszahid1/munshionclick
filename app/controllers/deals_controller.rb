# frozen_string_literal: true

# deals Controller
class DealsController < ApplicationController

  before_action :check_access
  before_action :set_deal, only: %i[show edit update destroy]
  require 'tempfile'
  require 'csv'
  # GET /deals
  # GET /deals.json
  def index
    if params.dig(:q, :created_at_gteq).present?
      params[:q][:created_at_gteq] = params[:q][:created_at_gteq]&.to_date&.beginning_of_day
      params[:q][:created_at_lteq] = params[:q][:created_at_lteq]&.to_date&.end_of_day
      @q = Deal.ransack(params[:q])
    else
      @q = Deal.where(created_at: DateTime.now.to_date&.beginning_of_month..DateTime.now.to_date&.end_of_month)
               .ransack(params[:q])
    end
    @total_commission = @q.result.sum(:comission)
    @total_earning = @q.result.sum(:agent_earning)
    @office_commission = @q.result.sum(:file_share)
    @deals = @q.result.page(params[:page]).per(25)
    @starting_number = 1 + 25 * ([params[:page].to_i, 1].max - 1)
    @staffs = Staff.all
    pdf_func if params[:pdf].present?
  end

  # GET /deals/1
  # GET /deals/1.json
  def show; end

  # GET /deals/new
  def new
    @deal = Deal.new
  end

  # GET /deals/1/edit
  def edit; end

  # POST /deals
  # POST /deals.json
  def create
    @deal = Deal.new(deal_params)

    respond_to do |format|
      if @deal.save
        format.js
        format.html { redirect_to deals_path, notice: 'Deal was successfully created.' }
        format.json { render :show, status: :created, location: @deal }
      else
        format.html { redirect_to deals_path, alert: 'Title is already present!' }
      end
    end
  end

  # PATCH/PUT /deals/1
  # PATCH/PUT /deals/1.json
  def update
    respond_to do |format|
      if @deal.update(deal_params)
        format.html { redirect_to deals_path, notice: 'Deal was successfully updated.' }
        format.json { render :show, status: :ok, location: @deal }
      else
        format.html { redirect_to deals_path, alert: 'Title is already present!' }
      end
    end
  end

  # DELETE /deals/1
  # DELETE /deals/1.json
  def destroy
    @deal.destroy
    respond_to do |format|
      format.html { redirect_to deals_path, notice: 'Deal was successfully Deleted.' }
      format.json { render :show, status: :ok, location: @deal }
    end
  end

  private

  # Use callbacks to share common setup or constraints between actions.
  def set_deal
    @deal = Deal.find(params[:id])
  end

  def pdf_func
    @deals = @q.result
    print_pdf('Agent-deals', 'pdf.html', 'A4')
  end

  # Never trust parameters from the scary internet, only allow the white list through.
  def deal_params
    params.require(:deal).permit(:deal_detail, :comission, :file_share, :share, :agent_earning, :staff_id)
  end

end
