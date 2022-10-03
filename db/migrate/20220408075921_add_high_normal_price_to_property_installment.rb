class AddHighNormalPriceToPropertyInstallment < ActiveRecord::Migration[6.1]
  def change
    add_column :property_installments, :high_price, :float
    add_column :property_installments, :normal_price, :float
  end
end
