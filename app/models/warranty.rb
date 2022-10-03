class Warranty < ApplicationRecord
  belongs_to :product
  has_paper_trail ignore: [:updated_at]
end
