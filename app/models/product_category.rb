
class ProductCategory < ApplicationRecord
  validates_uniqueness_of :code
  has_many :product_sub_categories
  has_many :products
  has_paper_trail ignore: [:updated_at]
  validates :title, presence: true, uniqueness: { case_sensitive: false }

end
