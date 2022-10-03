class AddLastInstallmentToPropertyPlan < ActiveRecord::Migration[5.2]
  def change
    add_column :property_plans, :last_instalment,:decimal, precision: 15, scale: 5,default:0
  end
end
