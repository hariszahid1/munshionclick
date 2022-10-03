class ProductionBlockType < ApplicationRecord
  enum status: %i[Active Passive]

  has_paper_trail ignore: [:updated_at]

end
