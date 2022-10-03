class ItemType < ApplicationRecord
  validates_uniqueness_of :code

  has_paper_trail ignore: [:updated_at]

  has_many :products
end