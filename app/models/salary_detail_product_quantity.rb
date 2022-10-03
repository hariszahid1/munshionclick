class SalaryDetailProductQuantity < ApplicationRecord
  belongs_to :staff
  belongs_to :product
  belongs_to :salary_detail, optional: true

  has_paper_trail ignore: [:updated_at]

end
