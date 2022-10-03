class StaffDeal < ApplicationRecord
  belongs_to :staff
  belongs_to :product
  has_paper_trail ignore: [:updated_at]
end
