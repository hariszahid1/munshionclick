class ImportMappingData < ActiveRecord::Migration[6.1]
  def change
    data = [
      ['Account', ["id", "title", "bank_name", "iban_number", "amount", "comment", "user_id"]],
      ['City', ["id", "title", "comment"] ],
      ['CompaignEntry', ["id", "name", "phone", "mobile", "email", "comment", "compaign_id"] ],
      ['Compaign', ["id", "title", "comment"] ],
      ['Contact', ["id", "address", "home", "office", "mobile", "fax", "email", "comment", "status", "country_id", "city_id", "sys_user_id", "permanent_address"] ],
      ['Country', ["id", "title", "comment"] ],
      ['Crontest', ["id", "name"] ],
      ['DailyBook', ["id", "book_date", "total_paid", "total_remaining", "department_id", "comment", "wage_rate", "quantity", "amount", "status", "extra", "coverge_rate", "wage_debit", "brick_rohra", "tile_rohra"] ],
      ['DailySale', ["id", "sale", "cash_out", "shift", "comment"] ],
      ['Department', ["id", "code", "title", "comment", "status"] ],
      ['ExpenseEntry', ["id", "amount", "expense_id", "expense_type_id", "account_id", "comment", "status", "expenseable_type", "expenseable_id"] ],
      ['ExpenseType', ["id", "title", "comment"] ],
      ['Expense', ["id", "expense", "comment", "expense_type_id", "account_id"] ],
      ['Gate', ["id", "pather_from", "pather_to", "kharkar_from", "kharkar_to", "bhari_from", "bhari_to", "jalai_from", "jalai_to", "nakasi_from", "nakasi_to", "comment", "pather_cost", "kharkar_cost", "jalai_cost", "nakasi_cost", "purchase_from", "purchase_to", "sale_from", "sale_to", "expense_from", "expense_to", "salary_from", "salary_to"] ],
      ['Help', ["id", "controller", "function", "page", "system_link", "help_links"] ],
      ['Investment', ["id", "invest", "comment", "account_id"] ],
      ['ItemType', ["id", "title", "code", "comment"] ],
      ['Item', ["id", "item_type_id", "title", "code", "minimum", "optimal", "maximun", "comment", "status", "purchase_type", "quantity_type", "weight_type", "stock", "cost", "sale", "location", "measurement_quantity"] ],
      ['LedgerBook', ["id", "sys_user_id", "debit", "credit", "balance", "comment", "purchase_sale_detail_id", "account_id", "order_id", "status", "bank_detail", "payment_method", "payment_detail"] ],
      ['Link', ["id", "linkable_type", "linkable_id", "qrcode", "brcode", "href", "title"] ],
      ['MapColumn', ["id", "table_column", "mapping_column", "table_name"] ],
      ['Material', ["id", "production_id", "item_id", "product_id", "cost_price", "sale_price", "total_cost_price", "total_sale_price", "quantity", "comment", "status"] ],
      ['OrderItem', ["id", "order_id", "product_id", "item_id", "quantity", "cost_price", "sale_price", "total_cost_price", "total_sale_price", "status", "comment", "transaction_type", "discount_price", "purchase_sale_type", "expiry_date", "marla", "square_feet", "gst", "gst_amount", "extra_expence"] ],
      ['Order', ["id", "sys_user_id", "transaction_type", "total_bill", "amount", "discount_price", "status", "comment", "voucher_id", "account_id", "carriage", "loading", "with_gst", "bank_detail", "payment_method", "payment_detail"] ],
      ['Payment', ["id", "debit", "credit", "account_id", "paymentable_type", "paymentable_id", "amount", "status", "comment", "confirmable", "confirmed_by", "confirmed_at"] ],
      ['PosSetting', ["id", "name", "display_name", "phone", "logo", "address", "sys_type", "account_id", "expiry_date", "invoice_note", "pdf_margin_top", "pdf_margin_right", "pdf_margin_bottom", "pdf_margin_left", "purchase_sale_detail_show_page_size", "purchase_sale_detail_show_line_height", "header", "footer", "header_logo_placement", "footer_address_placement", "logo_hieght", "logo_width", "header_hieght", "multi_language", "title_padding", "website", "gst", "ntn", "title_style", "image_style", "header_style", "footer_style", "is_sms", "is_qr", "sms_user", "sms_pass", "sms_mask", "sms_templates", "company_mask", "qr_links", "extra_settings"] ],
      ['ProductCategory', ["id", "code", "title", "comment"] ],
      ['ProductStockExchange', ["id", "product_id", "product_recipient_id", "quantity"] ],
      ['ProductStock', ["id", "product_id", "in_stock", "out_stock", "stock", "cost_price", "sale_price"] ],
      ['ProductSubCategory', ["id", "product_category_id", "code", "title", "comment"] ],
      ['ProductWarranty', ["id", "purchase_sale_detail_id", "product_id", "serial"] ],
      ['ProductionBlockType', ["id", "title", "quantity", "status", "comment"] ],
      ['ProductionBlock', ["id", "production_block_type_id", "title", "bricks_quantity", "tiles_quantity", "date", "status", "comment", "production_cycle_id", "bhari_production_block_id", "jalai_a", "jalai_b", "production_status", "purchase_sale_detail_id", "jalai_a_quantity", "jalai_b_quantity"] ],
      ['ProductionCycle', ["id", "start_date", "end_date", "status", "comment", "cycle_type", "item_id", "cost", "quantity", "total_cost", "measurement_quantity", "lines", "cost_per_line", "per_product_cost", "per_thousand_product_cost", "item_quantity_per_line", "total_item_quantity", "per_ton_bricks", "total_bricks"] ],
      ['Production', ["id", "product_id", "operation_cost", "cost_price", "sale_price", "comment", "status"] ],
      ['Product', ["id", "item_type_id", "code", "title", "product_category_id", "product_sub_category_id", "acquire_type", "purchase_type", "purchase_unit", "purchase_factor", "cost", "sale", "minimum", "optimal", "maximum", "currency", "comment", "stock", "location", "size_1", "size_2", "size_3", "size_4", "size_5", "size_6", "size_7", "size_8", "size_9", "size_10", "size_11", "size_12", "size_13", "product_type", "measurement_quantity", "raw_product_id", "gst", "vat", "hst", "pst", "qst", "with_serial", "warranty_list", "marla", "square_feet"] ],
      ['PropertyInstallment', ["id", "property_plan_id", "installment_no", "installment_price", "due_date", "due_status", "high_price", "normal_price", "bank_detail", "payment_method", "payment_detail"] ],
      ['PropertyPlan', ["id", "property_type", "area_in_marla", "price_per_marla", "total_price", "payment_type", "payment_plan", "no_of_installments", "advance", "high_amount_installments", "total_high_amount", "order_id", "last_instalment", "due_date", "due_status", "bank_detail", "payment_method", "payment_detail"] ],
      ['PurchaseSaleDetail', ["id", "sys_user_id", "transaction_type", "total_bill", "amount", "discount_price", "status", "comment", "voucher_id", "account_id", "carriage", "loading", "order_id", "staff_id", "bill_no", "user_name", "destination", "l_c", "g_d", "g_d_type", "g_d_date", "quantity", "dispatched_to", "despatch_date", "job_no", "reference_no", "company_name", "with_gst", "bank_detail", "payment_method", "payment_detail"] ],
      ['PurchaseSaleItem', ["id", "purchase_sale_detail_id", "item_id", "quantity", "cost_price", "sale_price", "total_cost_price", "total_sale_price", "status", "comment", "created_at", "updated_at", "product_id", "transaction_type", "size_1", "size_2", "size_3", "size_4", "size_5", "size_6", "size_7", "size_8", "size_9", "size_10", "size_11", "size_12", "size_13", "discount_price", "purchase_sale_type", "expiry_date", "remaining_quantity", "extra_expence", "extra_quantity", "gst", "gst_amount"] ],
      ['RawProduct', ["id", "code", "title", "stock", "acquire_type", "cost", "sale", "minimum", "optimal", "maximum", "first_stock", "second_stock", "third_stock", "nakasi_stock"] ],
      ['Remark', ["id", "user", "body", "message", "comment", "remark_type", "remarkable_type", "remarkable_id"] ],
      ['Salary', ["id", "paid_salary", "advance", "leaves_in_month", "staff_id", "paid_to", "payment_type", "advance_amount", "advance_due_till_this_transaction", "account_id", "comment", "balance", "total_balance"] ],
      ['SalaryDetailProductQuantity', ["id", "salary_detail_id", "staff_id", "product_id", "quantity"] ],
      ['SalaryDetail', ["id", "staff_id", "wage_rate", "quantity", "amount", "remarks", "comment", "product_id", "status", "extra", "daily_book_id", "raw_product_id", "raw_quantity", "raw_wage_rate", "gift_rate", "coverge_rate", "wage_debit", "gift_pay", "coverge_pay", "staff_pathera_id", "transaction_location", "khakar_quanity", "khakar_remaning", "khakar_debit", "khakar_wast", "khakar_extra", "khakar_credit", "pather_remaning_quanity", "pather_salary_detail_id", "purchase_sale_detail_id", "pather_khakar_wast", "balance", "total_balance"] ],
      ['SmsLog', ["id", "sms_from", "sms_to", "msg", "sms_by", "response"] ],
      ['StaffDeal', ["id", "staff_id", "product_id", "cost", "comment"] ],
      ['StaffLedgerBook', ["id", "staff_id", "salary_id", "salary_detail_id", "debit", "credit", "balance", "comment", "status", "bank_detail", "payment_method", "payment_detail"] ],
      ['StaffRawProduct', ["id", "staff_id", "raw_product_id"] ],
      ['Staff', ["id", "name", "father", "education", "phone", "address", "cnic", "date_of_joining", "yearly_increment", "monthly_salary", "staff_department", "gender", "advance_amount", "terminated", "terminated_at", "wage_rate", "comment", "balance", "department_id", "code", "staff_type", "wage_debit", "raw_product_quantity", "raw_product_quantity_tile"] ],
      ['SysUser', ["id", "code", "cnic", "name", "user_type_id", "user_group", "status", "occupation", "credit_status", "credit_limit", "opening_balance", "balance", "gst", "ntn", "father", "nom_name", "nom_father", "nom_cnic", "nom_relation"] ],
      ['UserType', ["id", "title", "code", "discount_by_percentage", "discount_by_amount", "comment"] ],
      ['Warranty', ["id", "serial_number", "comment", "product_id"] ],
    ]
    data.each do |d|
      ImportMapping.create(table_name: d[0] , included_fields: d[1])
    end
  end
end
