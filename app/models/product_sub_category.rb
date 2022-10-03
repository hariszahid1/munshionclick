class ProductSubCategory < ApplicationRecord
  belongs_to :product_category
  validates_uniqueness_of :code

  has_paper_trail ignore: [:updated_at]

end
