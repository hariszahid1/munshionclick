class CompaignEntry < ApplicationRecord
  belongs_to :compaign, optional: true
  has_paper_trail ignore: [:updated_at]
  def home
    self.phone+' '+self.mobile
  end

  def phone_with_comma
    ([self.phone]+[self.mobile]).uniq.reject(&:empty?).join(',')
  end

end
