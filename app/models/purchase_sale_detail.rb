class PurchaseSaleDetail < ApplicationRecord
  belongs_to :sys_user
  belongs_to :order, optional: true
  enum transaction_type: %i[Purchase Sale SaleReturn PurchaseReturn InWard OutWard InwardReturn OutWardReturn ReSaleDeal NewSaleDeal]
  enum status: %i[Clear Order UnClear]
  has_many :payments, as: :paymentable, dependent: :destroy
  has_many_attached :purchase_sale_images
  has_one :ledger_book, dependent: :destroy
  has_many :salary_details, dependent: :destroy
  belongs_to :staff, optional: true
  has_many :purchase_sale_items, dependent: :destroy
  has_many :expense_entries, as: :expenseable, dependent: :destroy
  accepts_nested_attributes_for :purchase_sale_items,reject_if: :check_rejectable?, allow_destroy: true
  accepts_nested_attributes_for :expense_entries,reject_if: :check_expense_rejectable?, allow_destroy: true
  belongs_to :account
  has_many :product_warranties, dependent: :destroy
  accepts_nested_attributes_for :product_warranties,reject_if: :all_blank, allow_destroy: true
  enum with_gst: %i[false true]
  has_paper_trail ignore: [:updated_at]
  has_many :follow_ups, as: :followable, dependent: :destroy
  accepts_nested_attributes_for :follow_ups, allow_destroy: true
  accepts_nested_attributes_for :sys_user

  after_create :modify_account_balance, :set_qr_code
  after_update :update_account_balance
  after_destroy :delete_account_balance
  before_create :generate_guid

  def check_rejectable?(attributes)
    if attributes['product_id'].blank? && attributes['item_id'].blank?
      return true
    else
      return false
    end
  end

  def check_expense_rejectable?(attributes)
    if attributes['amount'].blank? && attributes['expense_type_id'].blank? && attributes['account_id'].blank?
      return true
    else
      return false
    end
  end

  def update_account_balance
    if self.transaction_type=="Purchase" || self.transaction_type == 'InWard'
      if self.account_id?

        self.payments.update_all(account_id: self.account_id,debit:self.amount.to_f,comment: "Edit Purchase Voucher #"+self.id.to_s+"  ||  "+self.updated_at.strftime("%d/%b/%y at %I:%M%p"))
        # account = self.payments.first.account
        # total_balance = account.payments.sum(:credit)-account.payments.sum(:debit)
        # account.update(amount: total_balance)

        # balance=0
        # Payment.where(account_id: self.account_id).each do |lb|
        #   balance=balance+lb.credit.to_f-lb.debit.to_f
        #   if lb.amount!=balance
        #     lb.amount=balance
        #     lb.save!
        #   end
        # end
        # self.payments.first.account.update(amount:balance)
      end
    else
      if self.account_id?
        self.payments.update_all(account_id: self.account_id,credit:self.amount.to_f,comment: "Edit Sale Voucher #"+self.id.to_s+"  ||  "+self.updated_at.strftime("%d/%b/%y at %I:%M%p"))

        # account = self.payments.first.account
        # total_balance = account.payments.sum(:credit)-account.payments.sum(:debit)
        # account.update(amount: total_balance)

        # balance=0
        # Payment.where(account_id: self.account_id).each do |lb|
        #   balance=balance+lb.credit.to_f-lb.debit.to_f
        #   if lb.amount!=balance
        #     lb.amount=balance
        #     lb.save!
        #   end
        # end
        # self.payments.first.account.update(amount:balance)
      end
    end

    if self.ledger_book
      discount=self.discount_price.present? ? self.discount_price : 0
      if self.sys_user.user_group!='Supplier' && (self.transaction_type=="Sale" || self.transaction_type=="OutWard")
        self.ledger_book.update(sys_user_id: self.sys_user_id,debit:self.total_bill.to_f-discount,credit:self.amount.to_f,account_id: self.account_id)
      elsif self.sys_user.user_group=='Both'
        self.ledger_book.update(sys_user_id: self.sys_user_id,debit:self.amount.to_f,credit:self.total_bill.to_f-discount,account_id: self.account_id)
      else
        self.ledger_book.update(sys_user_id: self.sys_user_id,debit:self.amount.to_f,credit:self.total_bill.to_f-discount,account_id: self.account_id)
      end

      # balance = self&.sys_user&.opening_balance.to_f+(self&.sys_user&.ledger_books.sum(:credit)-self&.sys_user&.ledger_books.sum(:debit))
      # self.sys_user.update(balance: balance)

      # balance=self.ledger_book.sys_user.opening_balance.present? ? self.ledger_book.sys_user.opening_balance : 0
      # LedgerBook.where(sys_user_id: self.sys_user_id).each do |lb|
      #   balance=(balance+lb.credit.to_f)-lb.debit.to_f
      #   if lb.balance!=balance
      #     lb.balance=balance
      #     lb.save!
      #   end
      # end
    end
  end
  def delete_account_balance
  end

  def modify_account_balance
    if self.transaction_type=="Purchase"
      if self.account_id?
        self.payments.create(account_id: self.account_id,debit:self.amount.to_f,comment: "Purchase Voucher #"+self.id.to_s+"  ||  "+self.created_at.strftime("%d/%b/%y at %I:%M%p"))
      end
    elsif self.transaction_type == 'InWard'
      if self.account_id?
        self.payments.create(account_id: self.account_id,debit:self.amount.to_f,comment: "Inward Voucher #"+self.id.to_s+"  ||  "+self.created_at.strftime("%d/%b/%y at %I:%M%p"))
      end
    elsif self.transaction_type == 'OutWard'
      if self.account_id?
        self.payments.create(account_id: self.account_id,credit:self.amount.to_f,comment:"Outward Voucher #"+self.id.to_s+"  ||  "+self.created_at.strftime("%d/%b/%y at %I:%M%p"))
      end
    else
      if self.account_id?
        self.payments.create(account_id: self.account_id,credit:self.amount.to_f,comment:"Sale Voucher #"+self.id.to_s+"  ||  "+self.created_at.strftime("%d/%b/%y at %I:%M%p"))
      end
    end
  end

  def purchase_item_per_cost
    if purchase_sale_items.present?
      avg_carriage_loading = 0
      purchase_sale_item=purchase_sale_items.first
      quantity=purchase_sale_item.remaining_quantity.to_f
      cost_price=purchase_sale_item.cost_price.to_f
      expenses=self.expense_entries.sum(:amount)
      if carriage.to_f>0 || loading.to_f>0 || expenses>0
        avg_carriage_loading = (expenses+carriage.to_f+loading.to_f)/purchase_sale_item.remaining_quantity
      end
      return (cost_price+avg_carriage_loading).round(2),quantity
    else
      return 0,0
    end
  end
  def purchase_item_quantity
    if purchase_sale_items.present?
      purchase_sale_item=purchase_sale_items.first
      quantity=purchase_sale_item.quantity.to_f
      return quantity
    else
      return 0
    end
  end

  def purchase_item_measurement_quantity
    if purchase_sale_items.present?
      purchase_sale_item=purchase_sale_items.first
      quantity=0.1
      quantity=purchase_sale_items.first.item.measurement_quantity.to_f if purchase_sale_item.item.present?
      return quantity
    else
      return 1
    end
  end

  def purchase_sale_items_quantities
    if purchase_sale_items.present?
      return purchase_sale_items.sum(:quantity)
    else
      return 0
    end
  end

  def purchase_sale_items_names_and_quantity
    if purchase_sale_items.present?
      product_detail=[]
      purchase_sale_items.each do |item|
        if item.product_id.present?
          product_detail << [item&.product&.title, item.quantity, item.sale_price, item.total_sale_price, item.expiry_date, item.cost_price, item.total_cost_price, item.extra_expence,item&.product&.item_type&.title,item.purchase_sale_type,item.gst_amount,item&.product&.marla,item&.product&.square_feet]
        elsif item.item_id.present?
          product_detail << [item&.item&.title, item.quantity, item.sale_price, item.total_sale_price, item.expiry_date, item.cost_price, item.total_cost_price, item.extra_expence, item&.item&.item_type&.title,item.purchase_sale_type,item.gst_amount]
        end
      end
      # product_quantity=purchase_sale_items.group(:product_id).sum(:quantity)
      # product_quantity.each do |product|
      #   product_detail << [Product.find(product.first).title,  product.last] if product.first
      # end
      # product_quantity=purchase_sale_items.group(:item_id).sum(:quantity)
      # product_quantity.each do |product|
      #   product_detail << [Item.find(product.first).title,  product.last] if product.first
      # end
      return product_detail
    else
      return 0
    end
  end

  def staff_full_name
    self.staff.full_name if staff.present?
  end

  def generate_guid
    self.guid = SecureRandom.hex(6)
    generate_guid if PurchaseSaleDetail.exists?(guid: guid)
  end

  def set_qr_code
    if transaction_type == 'ReSaleDeal' || transaction_type == 'NewSaleDeal'
      update_column(:qr_code, PosSetting.first.website.to_s + '/sale_deals/' + self.id.to_s)
    else
      update_column(:qr_code, PosSetting.first.website.to_s +
        '/purchase_sale_details/' + self.id.to_s + '?' + 'receiveable=')
    end
  end
end
