class ItemType < ApplicationRecord
  validates_uniqueness_of :code
  validates :title, presence: true, uniqueness: { case_sensitive: false }

  has_paper_trail ignore: [:updated_at]
  
  has_many :products
end
