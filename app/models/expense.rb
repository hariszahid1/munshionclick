class Expense < ApplicationRecord
  belongs_to :expense_type, optional: true
  belongs_to :account, optional: true
  has_many :expense_entries, dependent: :destroy

  has_many :payment, as: :paymentable
  accepts_nested_attributes_for :expense_entries,reject_if: :all_blank, allow_destroy: true

  after_create :modify_salary_date_balance
  before_update :modify_salary_date_balance

  has_paper_trail ignore: [:updated_at]

  def modify_salary_date_balance
    if self.expense_entries.present?
        if created_at.strftime("%d%m%y")!=self.expense_entries.first.created_at.strftime("%d%m%y")
          self.expense_entries.update_all(created_at: self.created_at)
        end
    end
  end

end
