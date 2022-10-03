class PropertyPlan < ApplicationRecord
  has_many :property_installments, dependent: :destroy
  belongs_to :order
  enum property_type: %i[House Plot Shop Plaza]
  enum payment_method: %i[Cash Cheque PO DD]
  enum payment_type: %i[OnCash Installments]
  enum due_status: %i[Unpaid Paid]
  enum payment_plan: %i[Equal_Installments Unequal_Installments]
  accepts_nested_attributes_for :property_installments, allow_destroy: true

  has_paper_trail ignore: [:updated_at]

end
