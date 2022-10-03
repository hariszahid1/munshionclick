class Material < ApplicationRecord
  belongs_to :production , optional: true
  belongs_to :product, optional: true
  belongs_to :item, optional: true

  has_paper_trail ignore: [:updated_at]

end
