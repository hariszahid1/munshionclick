class Remark < ApplicationRecord
  belongs_to :remarkable, polymorphic: true
end
