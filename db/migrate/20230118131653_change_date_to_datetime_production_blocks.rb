class ChangeDateToDatetimeProductionBlocks < ActiveRecord::Migration[6.1]
  def change
    change_column :production_blocks, :date, :datetime, if_not_exists: true
  end
end
