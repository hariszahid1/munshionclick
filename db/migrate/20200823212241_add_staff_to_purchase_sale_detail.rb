class AddStaffToPurchaseSaleDetail < ActiveRecord::Migration[5.2]
  def change
    add_reference :purchase_sale_details, :staff
  end
end
