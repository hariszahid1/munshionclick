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
    @q = Deal.ransack(params[:q])
    @deals = @q.result.page(params[:page])
    @staffs = Staff.all
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

  # Never trust parameters from the scary internet, only allow the white list through.
  def deal_params
    params.require(:deal).permit(:deal_detail, :comission, :file_share, :share, :agent_earning, :staff_id)
  end

end
