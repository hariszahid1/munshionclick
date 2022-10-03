class AddPurchaseSaleDetailToSalaryDetail < ActiveRecord::Migration[5.2]
  def change
    add_reference :salary_details, :purchase_sale_detail
  end
end
