class StaffRawProduct < ApplicationRecord
  belongs_to :staff
  belongs_to :raw_product

  has_paper_trail ignore: [:updated_at]

end
