class ProductStockExchange < ApplicationRecord
  belongs_to :product
  belongs_to :product_recipient, :class_name => 'Product', :foreign_key => 'product_recipient_id'

  has_paper_trail ignore: [:updated_at]

end
