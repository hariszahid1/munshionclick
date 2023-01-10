# frozen_string_literal: true

class FollowUp < ApplicationRecord
  belongs_to :assigned_user, class_name: :User, optional: true, foreign_key: :assigned_to_id
  belongs_to :user, optional: true, foreign_key: :created_by
  belongs_to :followable, polymorphic: true
  enum task_type: {
    to_do: 'to do',
    Call: 'Call',
    Email: 'Email',
    Visit: 'Visit',
    Meet_up: 'Meet Up'
  }, _prefix: true

  enum priority: {
    low: 'Low',
    medium: 'Medium',
    high: 'High'
  }, _prefix: true

  enum reminder_type: {
    crms: 'CRM',
    expense_vouchers: 'ExpenseVoucher',
    orders: 'Order',
    purchase_sale_details: 'PurchaseSaleDetail',
    sale_deals: 'SaleDeal'
  }, _prefix: true
end
