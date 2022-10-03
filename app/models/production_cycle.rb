class ProductionCycle < ApplicationRecord
  has_many :production_blocks, dependent: :delete_all
  accepts_nested_attributes_for :production_blocks,reject_if: :all_blank, allow_destroy: true
  enum status: %i[bhari jalai nakasi]

  has_paper_trail ignore: [:updated_at]

  def production_blocks_bricks_quantity
    raw_quantity=production_blocks.pluck(:bricks_quantity)
    raw_quantity.compact.sum.round(2)
  end
  def production_blocks_bricks_quantity_with_date
    raw_quantity=production_blocks.group(:date).sum(:bricks_quantity)
    raw_quantity_with_date=Hash.new
    raw_quantity.each do |f|
      raw_quantity_with_date[f.first.strftime("%d/%m/%Y")]=f.last  if f.first.present?
    end
    raw_quantity_with_date
  end

  def production_blocks_tiles_quantity
    raw_quantity=production_blocks.pluck(:tiles_quantity)
    raw_quantity.compact.sum.round(2)
  end
  def production_blocks_tiles_quantity_with_date
    raw_quantity=production_blocks.group(:date).sum(:tiles_quantity)
    raw_quantity_with_date=Hash.new
    raw_quantity.each do |f|
      raw_quantity_with_date[f.first.strftime("%d/%m/%Y")]=f.last if f.first.present?
    end
    raw_quantity_with_date
  end

  def production_blocks_jalai_a_quantity
    raw_quantity=production_blocks.pluck(:jalai_a_quantity)
    raw_quantity.compact.sum.round(2)
  end
  def production_blocks_jalai_b_quantity
    raw_quantity=production_blocks.pluck(:jalai_b_quantity)
    raw_quantity.compact.sum.round(2)
  end

  def production_blocks_jalai_a
    raw_quantity=production_blocks.pluck(:jalai_a)
    raw_quantity.compact.sum.round(2)
  end
  def production_blocks_jalai_b
    raw_quantity=production_blocks.pluck(:jalai_b)
    raw_quantity.compact.sum.round(2)
  end
end
