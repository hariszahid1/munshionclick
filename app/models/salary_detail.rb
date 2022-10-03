class SalaryDetail < ApplicationRecord
  belongs_to :staff
  belongs_to :daily_book, optional: true
  belongs_to :product, optional: true
  belongs_to :raw_product, optional: true
  belongs_to :purchase_sale_detail, optional: true
  belongs_to :staff_pathera, class_name: "Staff", optional: true
  has_one :staff_ledger_book, dependent: :destroy
  has_many :payments, as: :paymentable, dependent: :destroy
  # belongs_to :pather_salary_detail_id, class_name: "SalaryDetail", optional: true
  # has_one :pathera_salary_detail, class_name: "SalaryDetail", foreign_key: "pather_salary_detail_id"
  has_many :salary_detail_product_quantities, dependent: :delete_all
  accepts_nested_attributes_for :salary_detail_product_quantities, reject_if: :all_blank, allow_destroy: true

  belongs_to :pather_salary_detail, :class_name => 'SalaryDetail', optional: true
  has_many :pather_salary_details, :class_name => 'SalaryDetail', :foreign_key => 'pather_salary_detail_id'
  has_one :pather_salary_detail, :class_name => 'SalaryDetail', :foreign_key => 'pather_salary_detail_id'

  enum transaction_location: %i[bhari stock chapa]

  after_create :modify_salary_date_balance
  before_update :modify_salary_date_balance
  after_create :create_total_balance
  after_update :update_total_balance
  after_destroy :delete_total_balance
  accepts_nested_attributes_for :payments,reject_if: :check_rejectable?, allow_destroy: true

  has_paper_trail ignore: [:updated_at]

  def check_rejectable?(attributes)
    if attributes['account_id'].blank?
      return true
    else
      return false
    end
  end

  def modify_salary_date_balance
    if self.salary_detail_product_quantities.present?
      if created_at.strftime("%d%m%y")!=self.salary_detail_product_quantities.first.created_at.strftime("%d%m%y")
        self.salary_detail_product_quantities.update_all(created_at: self.created_at)
      end
    end
  end

  def create_total_balance
    @departments=Department.all
    if PosSetting.first.sys_type=="batha"
      if self.staff.department_id==@departments.second.id && self.daily_book.present?
        khakar_credit=self.daily_book.salary_details.group(:staff_id).sum(:khakar_credit)
        khakar_credit[self.staff_id].present? ? khakar_balance=khakar_credit[self.staff_id] : khakar_balance=0
        self.staff.staff_ledger_books.last.present? ? balance=khakar_balance+self.staff.balance : balance=khakar_balance+self.staff.balance
        StaffLedgerBook.create(salary_detail_id:self.id,staff_id: self.staff.id,credit: (self.amount.to_f+self.khakar_credit.to_f),balance:balance,created_at: self.created_at)
      elsif (self.staff.department_id==@departments.first.id or self.staff.department_id==@departments.third.id) && self.daily_book.present?
        credit=self.daily_book.salary_details.group(:staff_id).sum(:amount)
        credit[self.staff_id].present? ? staff_balance=credit[self.staff_id] : staff_balance=0
        self.staff.staff_ledger_books.last.present? ? balance=staff_balance+self.staff.balance : balance=staff_balance+self.staff.balance
        StaffLedgerBook.create(salary_detail_id:self.id,staff_id: self.staff.id,credit: (self.amount.to_f+self.khakar_credit.to_f),balance:balance,created_at: self.created_at)
      elsif self.staff.department_id==@departments.fourth.id
        StaffLedgerBook.create(salary_detail_id:self.id,staff_id: self.staff.id,credit: (self.amount.to_f+self.khakar_credit.to_f),balance:self.total_balance,created_at: self.created_at)
      else
        StaffLedgerBook.create(salary_detail_id:self.id,staff_id: self.staff.id,credit: (self.amount.to_f+self.khakar_credit.to_f),balance:self.staff.balance,created_at: self.created_at)
      end
    else
      StaffLedgerBook.create(salary_detail_id:self.id,staff_id: self.staff.id,credit: (self.amount.to_f+self.khakar_credit.to_f),balance:self.staff.balance,created_at: self.created_at)
    end
  end

  def update_total_balance
    if self.staff_ledger_book.present?
      total_balance = (self&.staff&.staff_ledger_books.sum(:credit).to_f-self&.staff&.staff_ledger_books.sum(:debit).to_f)

      # total_balance = (self.staff_ledger_book.balance.to_f+(self.amount.to_f+self.khakar_credit.to_f)-self.staff_ledger_book.credit)
      self.staff_ledger_book.update(salary_detail_id:self.id, staff_id: self.staff.id, credit: (self.amount.to_f+self.khakar_credit.to_f),balance: total_balance,created_at: self.created_at) if self.staff_ledger_book.present?
      # balance=self.staff.present? ? total_balance : 0
      # staff_ledger_books = StaffLedgerBook.joins(:staff).where(staff_id: self.staff_id).where('credit>0 or debit>0').order('staffs.name asc', 'staff_ledger_books.created_at desc').first(10)
      # staff_ledger_books.each do |lb|
      #   if lb.balance!=balance
      #     lb.balance=balance
      #     lb.save!
      #   end
      #   balance=balance.to_f+(lb.debit.to_f-lb.credit.to_f)
      # end
    end
  end
  def delete_total_balance
    # if self.staff.present?
    #   balance=0
    #   staff_ledger_books = StaffLedgerBook.joins(:staff).where(staff_id: self.staff_id).where('credit>0 or debit>0').order('staffs.name asc', 'staff_ledger_books.created_at asc')
    #   staff_ledger_books.each do |lb|
    #     balance=balance.to_f+(lb.credit.to_f-lb.debit.to_f)
    #     if lb.balance!=balance
    #       lb.balance=balance
    #       lb.save!
    #     end
    #   end
    #   self.staff.update_column(:balance, balance)
    # end
  end

  def wage_debit_value
    wage_debit.present? ? wage_debit : 0
  end

  def amount_value
    amount.present? ? amount : 0
  end
# staff fuctions
  def staff_full_name
    staff.present? ? staff.full_name : ""
  end

  def staff_wage_debit_value
    (staff.wage_debit.present? ? staff.wage_debit : 0) if staff.present?
  end

  def raw_product_title
    raw_product.present? ? raw_product.title : ""
  end
end
