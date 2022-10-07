class Item < ApplicationRecord
  belongs_to :item_type
  enum status: %i[Active Passive]
  enum purchase_type: %i[Local Import]

  enum quantity_type: %i[Piece Weight Feet dumper]
  enum weight_type: %i[KG LTR Grams Sqr dumpar]

  has_paper_trail ignore: [:updated_at]

end
