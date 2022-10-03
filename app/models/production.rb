class Production < ApplicationRecord
  belongs_to :product , optional: true
  has_many :materials, dependent: :delete_all
  accepts_nested_attributes_for :materials,reject_if: :all_blank, allow_destroy: true

  has_paper_trail ignore: [:updated_at]

end
