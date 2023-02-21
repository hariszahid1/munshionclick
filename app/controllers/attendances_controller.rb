# frozen_string_literal: true

# Attendances Controller
class AttendancesController < ApplicationController
  include PdfCsvGeneralMethod

  before_action :check_access
  before_action :set_attendance, only: %i[show edit update destroy]
  before_action :set_staff, only: %i[edit new index show_staff]

  require 'tempfile'
  require 'csv'
  # GET /attendances
  # GET /attendances.json
  def index
    if params[:q].present?
      params[:q][:date_gteq] = params[:q][:date_gteq]&.to_date&.beginning_of_day
      params[:q][:date_lteq] = params[:q][:date_lteq]&.to_date&.end_of_day
    end
    @q = Attendance.includes(daily_attendances: :staff).order('date desc').ransack(params[:q])
    @attendances = @q.result.page(params[:page]).per(@custom_pagination)
  end

  def show_staff
    if params[:q].present?
      params[:q][:attendance_date_gteq] = params[:q][:attendance_date_gteq]&.to_date&.beginning_of_day
      params[:q][:attendance_date_lteq] = params[:q][:attendance_date_lteq]&.to_date&.end_of_day
    end
    @q = DailyAttendance.includes(:attendance).all.order('attendances.date desc').ransack(params[:q])
    @attendances = @q.result.page(params[:page]).per(@custom_pagination)
  end

  # GET /attendances/1
  # GET /attendances/1.json
  def show; end

  # GET /attendances/new
  def new
    @attendance = Attendance.new
    staff_ids = @staffs.pluck(:id)
    staff_ids.each do |staff_id|
      @attendance.daily_attendances.build(staff_id: staff_id)
    end
  end

  # GET /attendances/1/edit
  def edit; end

  # POST /attendances
  # POST /attendances.json
  def create
    @attendance = Attendance.new(attendance_params)
    respond_to do |format|
      if @attendance.save
        format.html { redirect_to attendances_path, notice: 'Attendance was successfully marked.' }
      else
        format.html { redirect_to request.referrer, alert: @attendance.errors.full_messages[0] }
      end
    end
  end

  # PATCH/PUT /attendances/1
  # PATCH/PUT /attendances/1.json
  def update
    respond_to do |format|
      if @attendance.update(attendance_params)
        format.html { redirect_to attendances_path, notice: 'Attendance was successfully updated.' }
      else
        format.html { redirect_to request.referrer, alert: @attendance.errors.full_messages[0] }
      end
    end
  end

  # DELETE /attendances/1
  # DELETE /attendances/1.json
  def destroy
    @attendance.destroy
    respond_to do |format|
      format.html { redirect_to attendances_url, notice: 'Attendance was successfully destroyed.' }
      format.json { head :no_content }
      format.js   { render layout: false }
    end
  end

  private

  # Use callbacks to share common setup or constraints between actions.
  def set_attendance
    @attendance = Attendance.find(params[:id])
  end

  # Never trust parameters from the scary internet, only allow the white list through.
  def attendance_params
    params.require(:attendance).permit(:date, :comment,
                                       daily_attendances_attributes: %i[id check_in check_out total_time comment
                                                                        staff_id attendance_id _destroy])
  end

  def set_staff
    @staffs = Staff.all
  end
end
