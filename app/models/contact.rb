class Contact < ApplicationRecord
  belongs_to :country
  belongs_to :city
  belongs_to :contactable, polymorphic: true
  enum status: %i[Permanent Current]
  has_paper_trail ignore: [:updated_at]
  def phone
    self.home+' '+self.office+' '+self.mobile
  end

  def phone_with_comma
    ([self.home]+[self.office]+[self.mobile]).uniq.reject(&:empty?).join(',')
  end
end
