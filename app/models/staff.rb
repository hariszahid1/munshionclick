class Staff < ApplicationRecord
  # has_paper_trail ignore: [:updated_at] only: [:monthly_salary]

  enum gender: %i[male female]
  enum staff_type: %i[active panding deleted]
  scope :with_active, -> { where(staff_type: :active) }
  belongs_to :department, optional: true
  has_one_attached :profile_image
  has_many :staff_raw_products
  has_many :salary_details
  has_many :salaries
  has_many :staff_ledger_books
  has_many :pathera_salary_details, class_name: "SalaryDetail", foreign_key: "staff_pathera_id"
  validates_uniqueness_of :code
  accepts_nested_attributes_for :staff_raw_products,reject_if: :all_blank, allow_destroy: true
  has_many :follow_ups, foreign_key: 'assigned_to_id', primary_key: 'id'
  has_many :notes, foreign_key: 'assigned_to_id', primary_key: 'id'
  has_paper_trail ignore: [:updated_at]
  has_one :contact, as: :contactable, dependent: :destroy
  accepts_nested_attributes_for :contact

  def full_name
    self.name.to_s+' '+self.father.to_s
  end

  def coded_full_name
    self.code+' '+self.name+' '+self.father
  end

  def staff_raw_products_titles
    products=self.staff_raw_products.pluck(:raw_product_id).uniq
    RawProduct.where(id:products).pluck(:title)
  end
  def staff_salary_or_wage
    return self.monthly_salary if self.monthly_salary.present?
    return self.wage_rate if self.wage_rate.present?
  end

  def self.pather_active_staff
    Staff.where(department_id:Department.first,staff_type: :active)
  end
  def self.loader_active_staff
    Staff.where(department_id:Department.fourth,staff_type: :active)
  end
  def self.active_staff(department)
    Staff.where(department_id:department,staff_type: :active)
  end
  def self.pather_pending_staff
    Staff.where(department_id:Department.first,staff_type: :panding)
  end
  def self.pather_deleted_staff
    Staff.where(department_id:Department.first,staff_type: :deleted)
  end
  def self.pather_staff
    Staff.where(department_id:2)
  end
end
