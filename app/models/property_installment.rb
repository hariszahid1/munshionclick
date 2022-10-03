class PropertyInstallment < ApplicationRecord
  belongs_to :property_plan
  enum due_status: %i[Unpaid Paid]
  enum payment_method: %i[Cash Cheque PO DD]

  has_paper_trail ignore: [:updated_at]

end
