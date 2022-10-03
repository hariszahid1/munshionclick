class AddMarlaAreaToProduct < ActiveRecord::Migration[5.2]
  def change
    add_column :products, :marla, :float
    add_column :products, :square_feet, :float
  end
end
