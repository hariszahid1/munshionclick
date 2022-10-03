class DailyBook < ApplicationRecord
  belongs_to :department
  has_many :salary_details, dependent: :destroy
  # has_one :staff_ledger_book, dependent: :destroy

  accepts_nested_attributes_for :salary_details,reject_if: proc { |attributes| attributes['staff_id'].blank? }, allow_destroy: true

  after_create :modify_salary_date_balance
  before_update :modify_salary_date_balance
  after_update :modify_quantity
  after_create :modify_quantity

  has_paper_trail ignore: [:updated_at]

  def modify_salary_date_balance
    if self.salary_details.present?
      if self.department==Department.first
        if book_date.strftime("%d%m%y")!=self.salary_details.first.created_at.strftime("%d%m%y")
          self.salary_details.update_all(created_at: self.book_date)
        end
      else
        if created_at.strftime("%d%m%y")!=self.salary_details.first.created_at.strftime("%d%m%y")
          self.salary_details.update_all(created_at: self.created_at)
        end
      end
    end
  end

  def modify_quantity
    self.salary_details.each do |salary_detail|
      if salary_detail.salary_detail_product_quantities.count>0
        salary_detail.quantity = salary_detail.salary_detail_product_quantities.sum(:quantity)
        salary_detail.save!
      end
    end
  end

  def salary_details_raw_quantity
    raw_quantity=self.salary_details.pluck(:raw_quantity)
    raw_quantity.compact.sum
  end

  def salary_details_f99_raw_quantity
    raw_quantity=self.salary_details.where(raw_product_id: RawProduct.first).pluck(:raw_quantity)
    raw_quantity.compact.sum
  end

  def salary_details_tile_raw_quantity
    raw_quantity=self.salary_details.where(raw_product_id: RawProduct.second).pluck(:raw_quantity)
    raw_quantity.compact.sum
  end

  def salary_details_khakar_f99_raw_quantity
    raw_quantity=self.salary_details.where(raw_product_id: RawProduct.first).pluck(:khakar_quanity)
    raw_quantity.compact.sum
  end

  def salary_details_khakar_tile_raw_quantity
    raw_quantity=self.salary_details.where(raw_product_id: RawProduct.second).pluck(:khakar_quanity)
    raw_quantity.compact.sum
  end

  def salary_details_quantity
    quantity=self.salary_details.pluck(:quantity)
    quantity.compact.sum
  end

  def salary_details_f99_quantity
    raw_quantity=self.salary_details.where(raw_product_id: RawProduct.first).pluck(:quantity)
    raw_quantity.compact.sum
  end

  def salary_details_tile_quantity
    raw_quantity=self.salary_details.where(raw_product_id: RawProduct.second).pluck(:quantity)
    raw_quantity.compact.sum
  end

  def salary_details_pather_remaning_quanity
    quantity=self.salary_details.pluck(:pather_remaning_quanity)
    quantity.compact.sum
  end


  def salary_details_raw_quantity_rate
    raw_wage_rate=self.salary_details.pluck(:wage_debit)
    raw_wage_rate.compact.sum
  end

  def salary_details_quantity_rate
    wage_rate=self.salary_details.pluck(:amount)
    wage_rate.compact.sum
  end

  def salary_details_wast
    wast=self.salary_details.pluck(:extra)
    wast.compact.sum
  end

  def salary_details_gift_rate
    gift_rate=self.salary_details.pluck(:gift_pay)
    gift_rate.compact.sum
  end

  def salary_details_coverge_rate
    coverge_rate=self.salary_details.pluck(:coverge_pay)
    coverge_rate.compact.sum
  end

  def salary_details_khakar_quantity
    khakar_quanity=self.salary_details.pluck(:khakar_quanity)
    khakar_quanity.compact.sum
  end
  def salary_details_khakar_quantity_from_pather
    khakar_quanity=self.salary_details.where.not(staff_pathera_id: nil).pluck(:khakar_quanity)
    khakar_quanity.compact.sum
  end
  def salary_details_khakar_quantity_from_stock
    khakar_quanity=self.salary_details.where(staff_pathera_id: nil).pluck(:khakar_quanity)
    khakar_quanity.compact.sum
  end

  def salary_details_khakar_remaning
    khakar_remaning=self.salary_details.pluck(:khakar_remaning)
    khakar_remaning.compact.sum
  end

  def salary_details_pather_remaning_quanity_bhari
    quantity=self.salary_details.where(transaction_location: :bhari).pluck(:khakar_remaning)
    quantity.compact.sum
  end
  def salary_details_pather_remaning_quanity_stock
    quantity=self.salary_details.where(transaction_location: :stock).pluck(:khakar_remaning)
    quantity.compact.sum
  end
  def salary_details_pather_remaning_quanity_chapa
    quantity=self.salary_details.where(transaction_location: :chapa).pluck(:khakar_remaning)
    quantity.compact.sum
  end


  def salary_details_khakar_debit
    khakar_quanity=self.salary_details.pluck(:khakar_debit)
    khakar_quanity.compact.sum
  end

  def salary_details_khakar_credit
    khakar_remaning=self.salary_details.pluck(:khakar_credit)
    khakar_remaning.compact.sum
  end

  def salary_details_khakar_wast
    khakar_remaning=self.salary_details.pluck(:khakar_wast)
    khakar_remaning.compact.sum
  end
  def salary_details_pather_khakar_wast
    khakar_remaning=self.salary_details.pluck(:pather_khakar_wast)
    khakar_remaning.compact.sum
  end

end
