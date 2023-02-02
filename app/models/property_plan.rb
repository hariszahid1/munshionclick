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

  scope :with_unpaid_installments, -> { joins(:property_installments).where(property_installments: { due_status: [nil, PropertyPlan.due_statuses['Unpaid']] }) }

  scope :with_installment_count_in_range, -> (min, max) do
    if min.present? && max.present?
      having("count(property_installments.property_plan_id) <= #{max} AND count(property_installments.property_plan_id) >= #{min}")
    elsif min.present?
      having("count(property_installments.property_plan_id) >= #{min}")
    elsif max.present?
      having("count(property_installments.property_plan_id) <= #{max}")
    end
  end

  scope :with_installment_amount_in_range, -> (min, max) do
    if min.present? && max.present?
      where("property_installments.installment_price <= #{max} AND property_installments.installment_price >= #{min}")
    elsif min.present?
      where("property_installments.installment_price >= #{min}")
    elsif max.present?
      where("property_installments.installment_price <= #{max}")
    end
  end

  def self.ransack_with_installment_count(params)
    property_plans = PropertyPlan.with_unpaid_installments
    if params[:installment_amount_from].present? || params[:installment_amount_to].present?
      property_plans = property_plans.with_installment_amount_in_range(params[:installment_amount_from], params[:installment_amount_to])
    end

    if params[:installment_count_from].present? || params[:installment_count_to].present?
      property_plans = property_plans.with_installment_count_in_range(params[:installment_count_from], params[:installment_count_to])
    end
    property_plans.ransack(params[:q]).result.group(:id).count.keys
  end

end
