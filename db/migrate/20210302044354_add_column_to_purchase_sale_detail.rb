class AddColumnToPurchaseSaleDetail < ActiveRecord::Migration[5.2]
  def change
    add_column :purchase_sale_details, :destination, :string
    add_column :purchase_sale_details, :l_c, :string
    add_column :purchase_sale_details, :g_d, :string
    add_column :purchase_sale_details, :g_d_type, :string
    add_column :purchase_sale_details, :g_d_date, :datetime
    add_column :purchase_sale_details, :quantity, :string
    add_column :purchase_sale_details, :dispatched_to, :string
    add_column :purchase_sale_details, :despatch_date, :datetime
    add_column :purchase_sale_details, :job_no, :string
    add_column :purchase_sale_details, :reference_no, :string
  end
end
