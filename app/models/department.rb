class Department < ApplicationRecord
  has_many :staffs
  validates_uniqueness_of :code

  has_paper_trail ignore: [:updated_at]

end
