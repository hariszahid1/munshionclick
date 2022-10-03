class AddBankToPropertyPlan < ActiveRecord::Migration[6.1]
  def change
    add_column :property_plans, :bank_detail,  :text
    add_column :property_installments, :bank_detail,  :text
    add_column :orders, :bank_detail,  :text
    add_column :purchase_sale_details, :bank_detail,  :text
    add_column :ledger_books, :bank_detail,  :text
    add_column :staff_ledger_books, :bank_detail,  :text

    add_column :property_plans, :payment_method,  :integer
    add_column :property_installments, :payment_method,  :integer
    add_column :orders, :payment_method,  :integer
    add_column :purchase_sale_details, :payment_method,  :integer
    add_column :ledger_books, :payment_method,  :integer
    add_column :staff_ledger_books, :payment_method,  :integer

    add_column :property_plans, :payment_detail,  :text
    add_column :property_installments, :payment_detail,  :text
    add_column :orders, :payment_detail,  :text
    add_column :purchase_sale_details, :payment_detail,  :text
    add_column :ledger_books, :payment_detail,  :text
    add_column :staff_ledger_books, :payment_detail,  :text

  end
end
