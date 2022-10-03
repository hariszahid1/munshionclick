class DailySale < ApplicationRecord
  enum shift: %i[Morning Evening]

  has_paper_trail ignore: [:updated_at]

end
