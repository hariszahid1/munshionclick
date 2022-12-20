class PdfTemplate < ApplicationRecord
  has_one_attached :logo
  has_many :pdf_template_elements
  has_paper_trail ignore: [:updated_at]
end
