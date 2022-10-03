class OrderItem < ApplicationRecord
  belongs_to :order, optional: true
  belongs_to :item, optional: true
  belongs_to :product, optional: true
  enum transaction_type: %i[Purchase Sale]
  enum purchase_sale_type: %i[Sale_type Return_type]
  enum status: %i[booked open secure only_booked]
  has_paper_trail ignore: [:updated_at]

end
