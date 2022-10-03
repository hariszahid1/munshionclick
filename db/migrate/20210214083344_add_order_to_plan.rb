class AddOrderToPlan < ActiveRecord::Migration[5.2]
  def change
    add_reference :property_plans, :order
    # remove_reference :orders, :property_plan, index: true
  end
end
