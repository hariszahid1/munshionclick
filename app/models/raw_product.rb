class RawProduct < ApplicationRecord
  validates_uniqueness_of :code

  has_paper_trail ignore: [:updated_at]

end
