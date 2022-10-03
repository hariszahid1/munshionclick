class Salary < ApplicationRecord
  belongs_to :staff
  enum paid_to: %i[Staff]
  enum payment_type: %i[Salary Advance Loan]
  has_many :payment, as: :paymentable
  has_one :staff_ledger_book, dependent: :destroy
  belongs_to :account
  validates :staff_id, presence: true

  after_create :modify_account_and_balance
  after_create :create_total_balance
  after_update :update_total_balance
  before_update :update_account_and_balance
  before_destroy :destroy_account_and_balance

  after_save :update_advance
  after_create :update_advance_to_zero

  has_paper_trail ignore: [:updated_at]

  def create_total_balance
    StaffLedgerBook.create(salary_id:self.id,staff_id: self.staff.id,debit: (self.advance.to_f+self.paid_salary.to_f),balance:self.staff.balance,created_at: self.created_at)
  end

  def update_total_balance
    self.staff_ledger_book.update(salary_id:self.id,staff_id: self.staff.id,debit: (self.advance.to_f+self.paid_salary.to_f),balance: self.staff_ledger_book.balance.to_f-(self.staff_ledger_book.debit.to_f+(self.advance.to_f+self.paid_salary.to_f))) if self.staff_ledger_book.present?
  end

  def update_advance
    already_advance = staff.advance_amount
    total_advance = already_advance.to_i + self.advance.to_i
    staff.update(advance_amount: total_advance)
    update_columns(advance_due_till_this_transaction: total_advance)
  end

  def update_advance_to_zero
    if self.Salary?
        staff.update(advance_amount: 0)
    end
  end
  def modify_account_and_balance
    salary = self.paid_salary.present? ? self.paid_salary : 0
    advance = self.advance.present? ? self.advance : 0
    total_paid = advance+salary
    staff_name = ""
    if self.staff_id?
      self.staff.balance.present? ?   balance=self.staff.balance-total_paid : balance=0
      self.staff.wage_debit.present? ?   wage_debit=self.staff.wage_debit-total_paid : wage_debit=0
      staff_name=self.staff.full_name
      if self.payment_type=="Loan"
        self.staff.update(balance: balance)
        if self.account_id?
          self.payment.create(account_id: self.account_id,debit:total_paid.to_i,comment: "Loan/pashgyi To "+staff_name)
        end
      else
        self.staff.update(balance: balance,wage_debit: wage_debit)
        if self.account_id?
          self.payment.create(account_id: self.account_id,debit:total_paid.to_i,comment: "Salary/Advance To "+staff_name)
        end
      end
    end
  end

  def update_account_and_balance
    salary_was = self.paid_salary_was.present? ? self.paid_salary_was : 0
    advance_was = self.advance_was.present? ? self.advance_was : 0
    salary = self.paid_salary.present? ? self.paid_salary : 0
    advance = self.advance.present? ? self.advance : 0
    total_paid = (advance+salary)
    total_paid_was = (advance_was+salary_was)

    if self.account_id?
      if total_paid_was>total_paid
        if self.payment.present?
          total_balance =self.payment.first.amount.to_f+total_paid
        end
      else
        if self.payment.present?
          total_balance =self.payment.first.amount.to_f-total_paid+total_paid_was
        end
      end
      self.payment.update(debit: total_paid.to_i,amount: total_balance,comment: "Edited Salary/Advance")

      account = Payment.where(account_id: self.account_id)
      balance = account.select('SUM(debit) as sum_debit','SUM(credit) as sum_credit','SUM(credit)-SUM(debit) as mean_sum').first.mean_sum
      account.order('id desc').first(50).each do |lb|
        if lb.amount!=balance
          lb.amount=balance
          lb.save!
        end
        balance = balance.to_f+(lb.debit.to_f-lb.credit.to_f)
      end

      if self.payment.present?
         self.payment.first.account.update(amount: balance)
      end
    end
    if self.staff_id?
      if total_paid_was>total_paid
        total_balance =self.staff.balance+total_paid
      else
        total_balance =self.staff.balance-total_paid+total_paid_was
      end
      total_balance =total_paid_was-total_paid
      self.staff.balance.present? ? balance=self.staff.balance+(total_balance) : balance=0
      self.staff.wage_debit.present? ? wage_debit=self.staff.wage_debit+(total_balance) : wage_debit=0
      self.staff.update(balance: balance,wage_debit: wage_debit)
    end
  end

  def destroy_account_and_balance
    salary_was = self.paid_salary_was.present? ? self.paid_salary_was : 0
    advance_was = self.advance_was.present? ? self.advance_was : 0
    amount = self.payment.present? ? self.payment.first.amount : 0
    total_paid = advance_was+salary_was
    total_balance =amount+total_paid
    if self.account_id?
      self.payment.update(debit:0,credit:0,amount:total_balance,comment: "Destory Salary/Advance")
    end
    if self.staff_id?
      self.staff.balance.present? ? balance=self.staff.balance+total_paid : balance=0
      self.staff.wage_debit.present? ? wage_debit=self.staff.wage_debit+total_paid : wage_debit=0
      self.staff.update(balance: balance,wage_debit: wage_debit)
    end
  end

end
