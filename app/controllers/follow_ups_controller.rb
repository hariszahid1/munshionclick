# frozen_string_literal: true

# Cities Controller
class FollowUpsController < ApplicationController
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

  private

  # Use callbacks to share common setup or constraints between actions.

  # Never trust parameters from the scary internet, only allow the white list through.
  def follow_up_params
    params.require(:follow_up).permit(:reminder_type, :task_type, :priority, :date, :created_by, :comment, :assigned_to_id, :followable_type, :followable_id)
  end
end
