class Product < ApplicationRecord
  belongs_to :product_category
  belongs_to :product_sub_category, optional: true
  belongs_to :raw_product, optional: true
  belongs_to :item_type
  has_one :product
  has_one :staff_deal
  has_many :links, as: :linkable
  has_many :order_items
  has_many :orders, through: :order_items
  has_many :purchase_sale_items
  accepts_nested_attributes_for :links, reject_if: :all_blank, allow_destroy: true
  has_many :product_warranties
  enum purchase_type: %i[Local Import]
  enum product_type: %i[product raw_product]
  enum hscheme_product_type: %i[OnCash OnInstallment]
  enum purchase_unit: %i[Piece Pack]
  enum acquire_type: %i[Outsource Manifacring]
  enum currency: %i[RS USD EURO SAR]
  enum plot_status: %i[booked_plot open_plot secure_plot only_booked_plot]
  has_many :product_stock_exchanges, :foreign_key => 'product_recipient_id'
  validates_uniqueness_of :code
  validates_uniqueness_of :title
  has_one_attached :profile_image
  before_create :generate_guid


  has_paper_trail ignore: [:updated_at]
  def category_title
    self.product_category&.title
  end
  scope :booked_plot, ->{ joins(:order_items)}
  scope :open_plot,   ->{ where( id: includes(:order_items).where(order_items: { product_id: nil }).pluck(:id) + includes(:order_items).where(order_items: {status: :open}).pluck(:id) )}
  scope :secure_plot, ->{ joins(:purchase_sale_items) }
  scope :only_booked_plot, ->{  joins(:order_items)-joins(:purchase_sale_items)}

  def generate_guid
    self.guid = SecureRandom.hex(6)
    generate_guid if Product.exists?(guid: guid)
  end
end
