# frozen_string_literal: true

class FollowUp < ApplicationRecord
  belongs_to :staff, optional: true, foreign_key: :assigned_to_id
  belongs_to :user, optional: true, foreign_key: :created_by
  belongs_to :followable, polymorphic: true
  enum task_type: {
    to_do: 'to do',
    Call: 'Call',
    Email: 'Email',
    Visit: 'Visit'
  }, _prefix: true

  enum priority: {
    low: 'Low',
    medium: 'Medium',
    high: 'High'
  }, _prefix: true

  enum reminder_type: {
    due_time: 'Due Time',
    thirty_minutes: '30 minutes Ago',
    one_day: '1 day ago'
  }, _prefix: true
end
