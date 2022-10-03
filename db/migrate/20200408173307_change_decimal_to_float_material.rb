class ChangeDecimalToFloatMaterial < ActiveRecord::Migration[5.0]
  def change
    change_column :materials, :cost_price, :float
    change_column :materials, :sale_price, :float
    change_column :materials, :total_cost_price, :float
    change_column :materials, :total_sale_price, :float
    change_column :materials, :quantity, :float
  end
end
