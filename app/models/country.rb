class Country < ApplicationRecord
  has_one:contact

  has_paper_trail ignore: [:updated_at]
  validates :title, presence: true, uniqueness: { case_sensitive: false }

end
