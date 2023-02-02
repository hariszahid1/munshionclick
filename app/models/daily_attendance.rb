# frozen_string_literal: true

# Daily Attendance Model
class DailyAttendance < ApplicationRecord
  belongs_to :attendance
  belongs_to :staff


  after_update :update_total_time
  after_create :update_total_time


  def check_in=(value)
    if value.is_a?(Hash) && value[4].present? && value[5].present?
      today = Date.today
      self[:check_in] = Time.zone.local(today.year, today.month, today.day, value[4], value[5])
    else
      self[:check_in] = nil
    end
  end

  def check_out=(value)
    if value.is_a?(Hash) && value[4].present? && value[5].present?
      today = Date.today
      self[:check_out] = Time.zone.local(today.year, today.month, today.day, value[4], value[5])
    else
      self[:check_out] = nil
    end
  end

  def update_total_time
    return if check_in.blank? || check_out.blank?

    difference = check_out - check_in
    total_time = Time.at(difference).utc.strftime('%H hours and %M minutes')
    update_column(:total_time, total_time)
  end
end

