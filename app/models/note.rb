class Note < ApplicationRecord
  belongs_to :assigned_user, class_name: :User, optional: true, foreign_key: :assigned_to_id
  belongs_to :user, optional: true, foreign_key: :created_by
  belongs_to :notable, polymorphic: true
end
