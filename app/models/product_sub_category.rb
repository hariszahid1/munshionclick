class ProductSubCategory < ApplicationRecord
  belongs_to :product_category
  has_many :products
  validates_uniqueness_of :code

  has_paper_trail ignore: [:updated_at]
  validates :title, presence: true, uniqueness: { case_sensitive: false }

  def as_json
    super.merge(product_category: product_category)
  end

end
