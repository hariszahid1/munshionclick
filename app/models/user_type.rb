class UserType < ApplicationRecord
  validates_uniqueness_of :code
end
