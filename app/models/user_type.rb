class UserType < ApplicationRecord
  validates_uniqueness_of :code
  validates :title, presence: true, uniqueness: { case_sensitive: false }
end
