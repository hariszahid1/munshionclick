class ProductWarranty < ApplicationRecord
  belongs_to :purchase_sale_detail, optional: true
  belongs_to :product

  has_paper_trail ignore: [:updated_at]

end
