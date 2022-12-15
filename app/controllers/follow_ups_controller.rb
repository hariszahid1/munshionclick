# frozen_string_literal: true

# FollowUps Controller
class FollowUpsController < ApplicationController
  before_action :set_follow_up, only: %i[show edit update destroy]

  # GET /follow_ups/1
  # GET /follow_ups/1.json
  def index
    @q = FollowUp.includes(:staff).ransack(params[:q])
    @q.sorts = 'id asc' if @q.sorts.empty? && @q.result.count.positive?
    @follow_ups = @q.result.page(params[:page])
    @options_for_select = SysUser.all
    @staff = Staff.all
    @follow_up_count = FollowUp.where(created_at: Time.current.all_day).count
    @total_follow_ups = FollowUp.count
  end

  # GET /follow_ups/1
  # GET /follow_ups/1.json
  def show
    respond_to do |format|
      format.js
    end
  end

  # GET /follow_ups/1/edit
  def edit; end

  # POST /followup
  # POST /followup.json
  def new
    @follow_up = FollowUp.new
    @staff = Staff.all
  end

  def create
    @follow_up = FollowUp.new(follow_up_params)
    respond_to do |format|
      if @follow_up.save
        format.js
        format.html { redirect_to customer_management_system_path(params[:follow_up][:followable_id].to_i), notice: 'Follow Up was successfully created.' }
        format.json { render :show, status: :created, location: @follow_up }
      else
        format.html { render :new }
        format.json { render json: @follow_up.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /follow_ups/1
  # PATCH/PUT /follow_ups/1.json
  def update
    respond_to do |format|
      if @follow_up.update(follow_up_params)
        format.html { redirect_to follow_ups_path, notice: 'Follow up was successfully updated.' }
        format.json { render :show, status: :ok, location: @follow_up }
      else
        format.html { render :edit }
        format.json { render json: @follow_up.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /follow_ups/1
  # DELETE /follow_ups/1.json
  def destroy
    @follow_up.destroy
    respond_to do |format|
      format.html { redirect_to follow_ups_path, notice: 'Folllow Up was successfully Deleted.' }
      format.json { render :show, status: :ok, location: @follow_up }
    end
  end



  private

  # Use callbacks to share common setup or constraints between actions.
  def set_follow_up
    @follow_up = FollowUp.find(params[:id])
    @staff = Staff.all
  end

  # Never trust parameters from the scary internet, only allow the white list through.
  def follow_up_params
    params.require(:follow_up).permit(:reminder_type, :task_type, :priority, :date, :created_by, :comment,
                                      :assigned_to_id, :followable_type, :followable_id)
  end
end
