class Compaign < ApplicationRecord
  has_many :compaign_entries, dependent: :destroy
  accepts_nested_attributes_for :compaign_entries,reject_if: :all_blank, allow_destroy: true
  has_paper_trail ignore: [:updated_at]

end
