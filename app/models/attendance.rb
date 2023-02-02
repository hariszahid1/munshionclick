# frozen_string_literal: true

# Daily Attendance Model
class Attendance < ApplicationRecord
  has_many :daily_attendances, dependent: :destroy
  accepts_nested_attributes_for :daily_attendances, allow_destroy: true
  validate :single_record_per_day

  private

  def single_record_per_day
    return unless id.nil? && Attendance.where(date: date.beginning_of_day..date.end_of_day).exists?

    errors.add(:attendance, 'can only have one record per day')
  end
end
