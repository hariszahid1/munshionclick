class PdfTemplateElement < ApplicationRecord
  belongs_to :pdf_template
  has_paper_trail ignore: [:updated_at]
end
