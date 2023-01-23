class Order < ApplicationRecord
  # acts_as_paranoid
  belongs_to :sys_user
  belongs_to :account
  has_many :property_plans, dependent: :destroy
  has_many_attached :order_images
  has_many :links, as: :linkable
  accepts_nested_attributes_for :links, reject_if: :all_blank, allow_destroy: true
  enum transaction_type: %i[Purchase Sale Inward Outward]
  enum status: %i[Clear Order UnClear UnPrint Printed Cancel]
  has_many :payment, as: :paymentable, dependent: :destroy
  has_one :ledger_book, dependent: :destroy
  has_many :order_items, dependent: :destroy
  has_many :purchase_sale_details, dependent: :destroy
  accepts_nested_attributes_for :order_items,reject_if: :check_rejectable?, allow_destroy: true
  accepts_nested_attributes_for :property_plans, allow_destroy: true
  enum with_gst: %i[false true]
  after_create :modify_account_balance
  after_update :update_account_balance
  has_many :remarks, as: :remarkable
  accepts_nested_attributes_for :remarks, allow_destroy: true
  before_create :generate_guid
  has_many :follow_ups, as: :followable, dependent: :destroy
  accepts_nested_attributes_for :follow_ups, allow_destroy: true

  has_paper_trail ignore: [:updated_at]

  def check_rejectable?(attributes)
    if attributes['product_id'].blank? && attributes['item_id'].blank?
      return true
    else
      return false
    end
  end

  def update_account_balance
    date = ERB::Util.url_encode(self.created_at.to_s)
    registration_no = ERB::Util.url_encode((self.sys_user&.code).to_s)
    cnic_no = ERB::Util.url_encode((self.sys_user&.cnic).to_s)
    member_name = ERB::Util.url_encode((self.sys_user.name).to_s)
    address = ERB::Util.url_encode((self.sys_user&.contact&.address).to_s)
    contacts = ERB::Util.url_encode((self.sys_user&.contact&.mobile).to_s)
    if self.order_items_names_and_quantity!=0
      self.order_items_names_and_quantity.each do |name_quantity|
        @block_name=name_quantity[6]
        @property_size=name_quantity.second.to_s+"M"
        @property_no=name_quantity.first
      end
    end
    balance = ERB::Util.url_encode((self&.sys_user&.balance.to_f).to_s)

    block_name    = ERB::Util.url_encode((@block_name).to_s)
    property_size = ERB::Util.url_encode((@property_size).to_s)
    property_no   = ERB::Util.url_encode((@property_no).to_s)
    link = self.links&.first&.update(qrcode: PosSetting.first.website.to_s+"/orders/"+self.id.to_s+"?"+"receivable="+PosSetting.first.company_mask.to_s)
    if link.blank?
      self.links.create(qrcode: PosSetting.first.website.to_s+"/orders/"+self.id.to_s+"?"+"receivable="+PosSetting.first.company_mask.to_s)
    end

    if self.transaction_type=="Purchase" || self.transaction_type=="Inward"
      if self.account_id?
        self.payment.update_all(account_id: self.account_id,debit:self.amount.to_f,comment: "Edit Purchase Order")

        account = self.payment.first.account
        total_balance = account.payments.sum(:credit)-account.payments.sum(:debit)
        account.update(amount: total_balance)

        # balance=0
        # Payment.where(account_id: self.account_id).each do |lb|
        #   balance=balance+lb.credit.to_f-lb.debit.to_f
        #   if lb.amount!=balance
        #     lb.amount=balance
        #     lb.save!
        #   end
        # end
        # self.payment.first.account.update(amount:balance)
      end
    else
      if self.account_id?
        self.payment.update_all(account_id: self.account_id,credit:self.amount.to_f,comment: "Edit Sale Order")
        account = self.payment.first.account
        total_balance = account.payments.sum(:credit)-account.payments.sum(:debit)
        account.update(amount: total_balance)

        # balance=0
        # Payment.where(account_id: self.account_id).each do |lb|
        #   balance=balance+lb.credit.to_f-lb.debit.to_f
        #   if lb.amount!=balance
        #     lb.amount=balance
        #     lb.save!
        #   end
        # end
        # self.payment.first.account.update(amount:balance)
      end
    end

    if self.ledger_book
      if self.sys_user.user_group=='Both' && self.transaction_type=="Sale"
        self.ledger_book.update(sys_user_id: self.sys_user_id,debit:0,credit:self.amount.to_f,account_id: self.account_id)
      elsif self.sys_user.user_group=='Both'
        self.ledger_book.update(sys_user_id: self.sys_user_id,debit:self.amount.to_f,credit:0,account_id: self.account_id)
      else
        self.ledger_book.update(sys_user_id: self.sys_user_id,debit:0,credit:self.amount.to_f,account_id: self.account_id)
      end
      # balance=self.ledger_book.sys_user.opening_balance.present? ? self.ledger_book.sys_user.opening_balance : 0

      balance = self&.sys_user&.opening_balance.to_f+(self&.sys_user&.ledger_books.sum(:credit)-self&.sys_user&.ledger_books.sum(:debit))
      self.sys_user.update(balance: balance)

      # LedgerBook.where(sys_user_id: self.sys_user_id).each do |lb|
      #   balance=(balance+lb.credit.to_f)-lb.debit.to_f
      #   if lb.balance!=balance
      #     lb.balance=balance
      #     lb.save!
      #   end
      # end
    end
  end
  def modify_account_balance

    date = ERB::Util.url_encode(self.created_at.to_s)
    registration_no = ERB::Util.url_encode((self.sys_user&.code).to_s)
    cnic_no = ERB::Util.url_encode((self.sys_user&.cnic).to_s)
    member_name = ERB::Util.url_encode((self.sys_user.name).to_s)
    address = ERB::Util.url_encode((self.sys_user&.contact&.address).to_s)
    contacts = ERB::Util.url_encode((self.sys_user&.contact&.mobile).to_s)
    if self.order_items_names_and_quantity!=0
      self.order_items_names_and_quantity.each do |name_quantity|
        @block_name=name_quantity[6]
        @property_size=name_quantity.second.to_s+"M"
        @property_no=name_quantity.first
      end
    end
    balance = ERB::Util.url_encode((self&.sys_user&.balance.to_f).to_s)

    block_name    = ERB::Util.url_encode((@block_name).to_s)
    property_size = ERB::Util.url_encode((@property_size).to_s)
    property_no   = ERB::Util.url_encode((@property_no).to_s)

    link = self.links&.first&.update(qrcode: PosSetting.first.website.to_s+"/orders/"+self.id.to_s+"?"+"receivable="+PosSetting.first.company_mask.to_s)
    if link.blank?
      self.links.create(qrcode: PosSetting.first.website.to_s+"/orders/"+self.id.to_s+"?"+"receivable="+PosSetting.first.company_mask.to_s)
    end

    if self.transaction_type=="Purchase"
      if self.account_id?
        self.payment.create(account_id: self.account_id,debit:self.amount.to_f,comment: "Purchase Order")
      end
    else
      if self.account_id?
        self.payment.create(account_id: self.account_id,credit:self.amount.to_f,comment:"Booking #"+self.id.to_s+"  ||  "+self.created_at.strftime("%d/%b/%y at %I:%M%p"))
      end
    end
  end

  def order_item_per_cost
    if order_items.present?
      avg_carriage_loading = 0
      purchase_sale_item=order_items.first
      quantity=purchase_sale_item.quantity.to_f
      cost_price=purchase_sale_item.cost_price.to_f
      if carriage.to_f>0 || loading.to_f>0
        avg_carriage_loading = (carriage.to_f+loading.to_f)/purchase_sale_item.quantity
      end
      return (cost_price+avg_carriage_loading).round(2),quantity
    else
      return 0,0
    end
  end
  def order_item_quantity
    if order_items.present?
      purchase_sale_item=order_items.first
      quantity=purchase_sale_item.quantity.to_f
      return quantity
    else
      return 0
    end
  end

  def order_item_measurement_quantity
    if order_items.present?
      purchase_sale_item=order_items.first
      quantity=0.1
      quantity=order_items.first.item.measurement_quantity.to_f if purchase_sale_item.item.present?
      return quantity
    else
      return 1
    end
  end

  def order_items_names_and_quantity
    if order_items.present?
      product_detail=[]
      order_items.each do |item|
        if item.product_id.present?
          product = Product.find(item.product_id)
          product_detail << [product.title, item.quantity, item.sale_price, item.total_sale_price, item.expiry_date,item.product&.category_title,product.item_type&.title,product.code,product.marla,product.square_feet]
        else
          custom_item = Item.find(item.item_id)
          product_detail << [custom_item.title, item.quantity, item.sale_price, item.total_sale_price, item.expiry_date,custom_item.item_type.title]
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

  def order_plot_dealer
    if order_items.present?
      product_detail=[]
      order_items.each do |item|
        if item.product_id.present?
          product = Product.find(item.product_id)
          product_detail << product.staff_deal
        end
      end
      return product_detail
    else
      return 0
    end
  end

  def generate_guid
    self.guid = SecureRandom.hex(6)
    generate_guid if Order.exists?(guid: guid)
  end
end
