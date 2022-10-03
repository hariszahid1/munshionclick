class ProductionBlock < ApplicationRecord
  belongs_to :production_block_type, optional: true
  belongs_to :production_cycle
  belongs_to :purchase_sale_detail, optional: true
  enum status: %i[bhari jalai nakasi]
  enum production_status: %i[Complete Uncomplete]
  # belongs_to :bhari_production_block, :class_name => 'ProductionBlock', optional: true
  # has_many :bhari_production_blocks, :class_name => 'ProductionBlock', :foreign_key => 'bhari_production_block_id'
  # has_one :bhari_production_block, :class_name => 'ProductionBlock', :foreign_key => 'bhari_production_block_id'

  has_many :bhari_production_blocks, class_name: "ProductionBlock", foreign_key: "bhari_production_block_id"
  belongs_to :bhari_production_block, class_name: "ProductionBlock", optional: true

  has_paper_trail ignore: [:updated_at]

end
