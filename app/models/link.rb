class Link < ApplicationRecord
  belongs_to :linkable, polymorphic: true
  has_paper_trail ignore: [:updated_at]
end
