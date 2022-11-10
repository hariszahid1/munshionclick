# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# This file is the source Rails uses to define your schema when running `bin/rails
# db:schema:load`. When creating a new database, `bin/rails db:schema:load` tends to
# be faster and is potentially less error prone than running all of your
# migrations from scratch. Old migrations may fail to apply correctly if those
# migrations use external dependencies or application code.
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema.define(version: 2022_08_17_103820) do

  create_table "accounts", id: :integer, charset: "utf8mb4", collation: "utf8mb4_unicode_ci", options: "ENGINE=InnoDB ROW_FORMAT=DYNAMIC", force: :cascade do |t|
    t.string "title"
    t.string "bank_name"
    t.string "iban_number"
    t.decimal "amount", precision: 15, scale: 5
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.text "comment"
    t.bigint "user_id"
    t.index ["user_id"], name: "index_accounts_on_user_id"
  end

  create_table "active_storage_attachments", id: :integer, charset: "utf8mb4", collation: "utf8mb4_unicode_ci", options: "ENGINE=InnoDB ROW_FORMAT=DYNAMIC", force: :cascade do |t|
    t.string "name", null: false
    t.string "record_type", null: false
    t.integer "record_id", null: false
    t.integer "blob_id", null: false
    t.datetime "created_at", null: false
    t.index ["blob_id"], name: "index_active_storage_attachments_on_blob_id"
    t.index ["record_type", "record_id", "name", "blob_id"], name: "index_active_storage_attachments_uniqueness", unique: true
  end

  create_table "active_storage_blobs", id: :integer, charset: "utf8mb4", collation: "utf8mb4_unicode_ci", options: "ENGINE=InnoDB ROW_FORMAT=DYNAMIC", force: :cascade do |t|
    t.string "key", null: false
    t.string "filename", null: false
    t.string "content_type"
    t.text "metadata"
    t.bigint "byte_size", null: false
    t.string "checksum", null: false
    t.datetime "created_at", null: false
    t.string "service_name", null: false
    t.index ["key"], name: "index_active_storage_blobs_on_key", unique: true
  end

  create_table "active_storage_variant_records", charset: "utf8mb4", collation: "utf8mb4_unicode_ci", options: "ENGINE=InnoDB ROW_FORMAT=DYNAMIC", force: :cascade do |t|
    t.bigint "blob_id", null: false
    t.string "variation_digest", null: false
    t.index ["blob_id", "variation_digest"], name: "index_active_storage_variant_records_uniqueness", unique: true
  end

  create_table "activities", charset: "utf8mb4", collation: "utf8mb4_unicode_ci", options: "ENGINE=InnoDB ROW_FORMAT=DYNAMIC", force: :cascade do |t|
    t.string "trackable_type"
    t.bigint "trackable_id"
    t.string "owner_type"
    t.bigint "owner_id"
    t.string "key"
    t.text "parameters"
    t.string "recipient_type"
    t.bigint "recipient_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["owner_id", "owner_type"], name: "index_activities_on_owner_id_and_owner_type"
    t.index ["owner_type", "owner_id"], name: "index_activities_on_owner_type_and_owner_id"
    t.index ["recipient_id", "recipient_type"], name: "index_activities_on_recipient_id_and_recipient_type"
    t.index ["recipient_type", "recipient_id"], name: "index_activities_on_recipient_type_and_recipient_id"
    t.index ["trackable_id", "trackable_type"], name: "index_activities_on_trackable_id_and_trackable_type"
    t.index ["trackable_type", "trackable_id"], name: "index_activities_on_trackable_type_and_trackable_id"
  end

  create_table "cities", id: :integer, charset: "utf8mb4", collation: "utf8mb4_unicode_ci", options: "ENGINE=InnoDB ROW_FORMAT=DYNAMIC", force: :cascade do |t|
    t.string "title"
    t.text "comment"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "compaign_entries", charset: "utf8mb4", collation: "utf8mb4_unicode_ci", options: "ENGINE=InnoDB ROW_FORMAT=DYNAMIC", force: :cascade do |t|
    t.string "name"
    t.string "phone"
    t.string "mobile"
    t.string "email"
    t.text "comment"
    t.bigint "compaign_id"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["compaign_id"], name: "index_compaign_entries_on_compaign_id"
  end

  create_table "compaigns", charset: "utf8mb4", collation: "utf8mb4_unicode_ci", options: "ENGINE=InnoDB ROW_FORMAT=DYNAMIC", force: :cascade do |t|
    t.string "title"
    t.text "comment"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
  end

  create_table "contacts", id: :integer, charset: "utf8mb4", collation: "utf8mb4_unicode_ci", options: "ENGINE=InnoDB ROW_FORMAT=DYNAMIC", force: :cascade do |t|
    t.string "address"
    t.string "home"
    t.string "office"
    t.string "mobile"
    t.string "fax"
    t.string "email"
    t.text "comment"
    t.integer "status"
    t.integer "country_id"
    t.integer "city_id"
    t.integer "sys_user_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.text "permanent_address"
    t.index ["city_id"], name: "index_contacts_on_city_id"
    t.index ["country_id"], name: "index_contacts_on_country_id"
    t.index ["sys_user_id"], name: "index_contacts_on_sys_user_id"
  end

  create_table "countries", id: :integer, charset: "utf8mb4", collation: "utf8mb4_unicode_ci", options: "ENGINE=InnoDB ROW_FORMAT=DYNAMIC", force: :cascade do |t|
    t.string "title"
    t.text "comment"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "crontests", charset: "utf8mb4", collation: "utf8mb4_unicode_ci", options: "ENGINE=InnoDB ROW_FORMAT=DYNAMIC", force: :cascade do |t|
    t.string "name"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "daily_books", charset: "utf8mb4", collation: "utf8mb4_unicode_ci", options: "ENGINE=InnoDB ROW_FORMAT=DYNAMIC", force: :cascade do |t|
    t.datetime "book_date"
    t.float "total_paid"
    t.float "total_remaining"
    t.bigint "department_id"
    t.text "comment"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.float "wage_rate", default: 0.0
    t.float "quantity", default: 0.0
    t.float "amount", default: 0.0
    t.integer "status"
    t.integer "extra", default: 0
    t.float "coverge_rate", default: 0.0
    t.float "wage_debit", default: 0.0
    t.integer "brick_rohra", default: 0
    t.integer "tile_rohra", default: 0
    t.index ["department_id"], name: "index_daily_books_on_department_id"
  end

  create_table "daily_sales", id: :integer, charset: "utf8mb4", collation: "utf8mb4_unicode_ci", options: "ENGINE=InnoDB ROW_FORMAT=DYNAMIC", force: :cascade do |t|
    t.decimal "sale", precision: 10
    t.decimal "cash_out", precision: 10
    t.integer "shift"
    t.text "comment"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "departments", id: :integer, charset: "utf8mb4", collation: "utf8mb4_unicode_ci", options: "ENGINE=InnoDB ROW_FORMAT=DYNAMIC", force: :cascade do |t|
    t.string "code"
    t.string "title"
    t.text "comment"
    t.integer "status"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "expense_entries", id: :integer, charset: "utf8mb4", collation: "utf8mb4_unicode_ci", options: "ENGINE=InnoDB ROW_FORMAT=DYNAMIC", force: :cascade do |t|
    t.float "amount"
    t.integer "expense_id"
    t.integer "expense_type_id"
    t.integer "account_id"
    t.text "comment"
    t.integer "status"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "expenseable_type"
    t.bigint "expenseable_id"
    t.index ["account_id"], name: "index_expense_entries_on_account_id"
    t.index ["expense_id"], name: "index_expense_entries_on_expense_id"
    t.index ["expense_type_id"], name: "index_expense_entries_on_expense_type_id"
    t.index ["expenseable_type", "expenseable_id"], name: "index_expense_entries_on_expenseable_type_and_expenseable_id"
  end

  create_table "expense_types", id: :integer, charset: "utf8mb4", collation: "utf8mb4_unicode_ci", options: "ENGINE=InnoDB ROW_FORMAT=DYNAMIC", force: :cascade do |t|
    t.string "title"
    t.text "comment"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "expenses", id: :integer, charset: "utf8mb4", collation: "utf8mb4_unicode_ci", options: "ENGINE=InnoDB ROW_FORMAT=DYNAMIC", force: :cascade do |t|
    t.float "expense"
    t.text "comment"
    t.integer "expense_type_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "account_id"
    t.index ["account_id"], name: "index_expenses_on_account_id"
    t.index ["expense_type_id"], name: "index_expenses_on_expense_type_id"
  end

  create_table "gates", charset: "utf8mb4", collation: "utf8mb4_unicode_ci", options: "ENGINE=InnoDB ROW_FORMAT=DYNAMIC", force: :cascade do |t|
    t.datetime "pather_from"
    t.datetime "pather_to"
    t.datetime "kharkar_from"
    t.datetime "kharkar_to"
    t.datetime "bhari_from"
    t.datetime "bhari_to"
    t.datetime "jalai_from"
    t.datetime "jalai_to"
    t.datetime "nakasi_from"
    t.datetime "nakasi_to"
    t.text "comment"
    t.decimal "pather_cost", precision: 10
    t.decimal "kharkar_cost", precision: 10
    t.decimal "jalai_cost", precision: 10
    t.decimal "nakasi_cost", precision: 10
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.datetime "purchase_from"
    t.datetime "purchase_to"
    t.datetime "sale_from"
    t.datetime "sale_to"
    t.datetime "expense_from"
    t.datetime "expense_to"
    t.datetime "salary_from"
    t.datetime "salary_to"
  end

  create_table "investments", id: :integer, charset: "utf8mb4", collation: "utf8mb4_unicode_ci", options: "ENGINE=InnoDB ROW_FORMAT=DYNAMIC", force: :cascade do |t|
    t.integer "invest"
    t.text "comment"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "account_id"
    t.index ["account_id"], name: "index_investments_on_account_id"
  end

  create_table "item_types", id: :integer, charset: "utf8mb4", collation: "utf8mb4_unicode_ci", options: "ENGINE=InnoDB ROW_FORMAT=DYNAMIC", force: :cascade do |t|
    t.string "title"
    t.string "code"
    t.text "comment"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "items", id: :integer, charset: "utf8mb4", collation: "utf8mb4_unicode_ci", options: "ENGINE=InnoDB ROW_FORMAT=DYNAMIC", force: :cascade do |t|
    t.integer "item_type_id"
    t.string "title"
    t.string "code"
    t.integer "minimum"
    t.integer "optimal"
    t.integer "maximun"
    t.text "comment"
    t.integer "status"
    t.integer "purchase_type"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "quantity_type"
    t.integer "weight_type"
    t.float "stock"
    t.float "cost"
    t.float "sale"
    t.string "location"
    t.float "measurement_quantity"
    t.index ["item_type_id"], name: "index_items_on_item_type_id"
  end

  create_table "ledger_books", id: :integer, charset: "utf8mb4", collation: "utf8mb4_unicode_ci", options: "ENGINE=InnoDB ROW_FORMAT=DYNAMIC", force: :cascade do |t|
    t.integer "sys_user_id"
    t.decimal "debit", precision: 15, scale: 5
    t.decimal "credit", precision: 15, scale: 5
    t.decimal "balance", precision: 15, scale: 5
    t.text "comment"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "purchase_sale_detail_id"
    t.integer "account_id"
    t.bigint "order_id"
    t.integer "status"
    t.text "bank_detail"
    t.integer "payment_method"
    t.text "payment_detail"
    t.datetime "deleted_at"
    t.index ["account_id"], name: "index_ledger_books_on_account_id"
    t.index ["deleted_at"], name: "index_ledger_books_on_deleted_at"
    t.index ["order_id"], name: "index_ledger_books_on_order_id"
    t.index ["purchase_sale_detail_id"], name: "index_ledger_books_on_purchase_sale_detail_id"
    t.index ["sys_user_id"], name: "index_ledger_books_on_sys_user_id"
  end

  create_table "links", charset: "utf8mb4", collation: "utf8mb4_unicode_ci", options: "ENGINE=InnoDB ROW_FORMAT=DYNAMIC", force: :cascade do |t|
    t.string "linkable_type"
    t.bigint "linkable_id"
    t.text "qrcode"
    t.text "brcode"
    t.text "href"
    t.text "title"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["linkable_type", "linkable_id"], name: "index_links_on_linkable_type_and_linkable_id"
  end

  create_table "map_columns", charset: "utf8", force: :cascade do |t|
    t.string "table_column"
    t.string "mapping_column"
    t.string "table_name"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
  end

  create_table "materials", id: :integer, charset: "utf8mb4", collation: "utf8mb4_unicode_ci", options: "ENGINE=InnoDB ROW_FORMAT=DYNAMIC", force: :cascade do |t|
    t.integer "production_id"
    t.integer "item_id"
    t.integer "product_id"
    t.float "cost_price"
    t.float "sale_price"
    t.float "total_cost_price"
    t.float "total_sale_price"
    t.float "quantity"
    t.text "comment"
    t.integer "status"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["item_id"], name: "index_materials_on_item_id"
    t.index ["product_id"], name: "index_materials_on_product_id"
    t.index ["production_id"], name: "index_materials_on_production_id"
  end

  create_table "order_items", charset: "utf8mb4", collation: "utf8mb4_unicode_ci", options: "ENGINE=InnoDB ROW_FORMAT=DYNAMIC", force: :cascade do |t|
    t.bigint "order_id"
    t.bigint "product_id"
    t.bigint "item_id"
    t.float "quantity"
    t.float "cost_price"
    t.float "sale_price"
    t.float "total_cost_price"
    t.float "total_sale_price"
    t.integer "status"
    t.text "comment"
    t.integer "transaction_type"
    t.float "discount_price"
    t.integer "purchase_sale_type"
    t.datetime "expiry_date"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.float "marla"
    t.float "square_feet"
    t.decimal "gst", precision: 15, scale: 2
    t.decimal "gst_amount", precision: 15, scale: 2
    t.float "extra_expence"
    t.datetime "deleted_at"
    t.index ["deleted_at"], name: "index_order_items_on_deleted_at"
    t.index ["item_id"], name: "index_order_items_on_item_id"
    t.index ["order_id"], name: "index_order_items_on_order_id"
    t.index ["product_id"], name: "index_order_items_on_product_id"
  end

  create_table "orders", charset: "utf8mb4", collation: "utf8mb4_unicode_ci", options: "ENGINE=InnoDB ROW_FORMAT=DYNAMIC", force: :cascade do |t|
    t.bigint "sys_user_id"
    t.integer "transaction_type"
    t.float "total_bill"
    t.float "amount"
    t.float "discount_price"
    t.integer "status"
    t.text "comment"
    t.integer "voucher_id"
    t.bigint "account_id"
    t.float "carriage"
    t.float "loading"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "with_gst"
    t.text "bank_detail"
    t.integer "payment_method"
    t.text "payment_detail"
    t.datetime "deleted_at"
    t.index ["account_id"], name: "index_orders_on_account_id"
    t.index ["deleted_at"], name: "index_orders_on_deleted_at"
    t.index ["sys_user_id"], name: "index_orders_on_sys_user_id"
  end

  create_table "payments", id: :integer, charset: "utf8mb4", collation: "utf8mb4_unicode_ci", options: "ENGINE=InnoDB ROW_FORMAT=DYNAMIC", force: :cascade do |t|
    t.decimal "debit", precision: 15, scale: 5
    t.decimal "credit", precision: 15, scale: 5
    t.integer "account_id"
    t.string "paymentable_type"
    t.integer "paymentable_id"
    t.decimal "amount", precision: 15, scale: 5
    t.integer "status"
    t.text "comment"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "confirmable"
    t.integer "confirmed_by"
    t.datetime "confirmed_at"
    t.datetime "deleted_at"
    t.index ["account_id"], name: "index_payments_on_account_id"
    t.index ["deleted_at"], name: "index_payments_on_deleted_at"
    t.index ["paymentable_type", "paymentable_id"], name: "index_payments_on_paymentable_type_and_paymentable_id"
  end

  create_table "pos_settings", id: :integer, charset: "utf8mb4", collation: "utf8mb4_unicode_ci", options: "ENGINE=InnoDB ROW_FORMAT=DYNAMIC", force: :cascade do |t|
    t.string "name", null: false
    t.string "display_name"
    t.string "phone"
    t.string "logo"
    t.text "address"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "sys_type"
    t.bigint "account_id"
    t.datetime "expiry_date"
    t.text "invoice_note"
    t.integer "pdf_margin_top", default: 0
    t.integer "pdf_margin_right", default: 0
    t.integer "pdf_margin_bottom", default: 0
    t.integer "pdf_margin_left", default: 0
    t.string "purchase_sale_detail_show_page_size", default: "A4"
    t.integer "purchase_sale_detail_show_line_height", default: 20
    t.boolean "header", default: true
    t.boolean "footer", default: true
    t.string "header_logo_placement", default: "logo_disable_text_center"
    t.string "footer_address_placement", default: "center"
    t.string "logo_hieght", default: "200"
    t.string "logo_width", default: "200"
    t.string "header_hieght", default: "50"
    t.boolean "multi_language", default: false
    t.string "title_padding", default: "10"
    t.text "website"
    t.text "gst"
    t.text "ntn"
    t.text "title_style"
    t.text "image_style"
    t.text "header_style"
    t.text "footer_style"
    t.boolean "is_sms", default: false
    t.boolean "is_qr", default: false
    t.text "sms_user"
    t.text "sms_pass"
    t.text "sms_mask"
    t.json "sms_templates"
    t.string "company_mask"
    t.json "qr_links"
    t.json "extra_settings"
    t.index ["account_id"], name: "index_pos_settings_on_account_id"
  end

  create_table "product_categories", id: :integer, charset: "utf8mb4", collation: "utf8mb4_unicode_ci", options: "ENGINE=InnoDB ROW_FORMAT=DYNAMIC", force: :cascade do |t|
    t.string "code"
    t.string "title"
    t.text "comment"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "product_stock_exchanges", charset: "utf8mb4", collation: "utf8mb4_unicode_ci", options: "ENGINE=InnoDB ROW_FORMAT=DYNAMIC", force: :cascade do |t|
    t.bigint "product_id"
    t.integer "product_recipient_id"
    t.integer "quantity"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["product_id"], name: "index_product_stock_exchanges_on_product_id"
  end

  create_table "product_stocks", charset: "utf8mb4", collation: "utf8mb4_unicode_ci", options: "ENGINE=InnoDB ROW_FORMAT=DYNAMIC", force: :cascade do |t|
    t.bigint "product_id"
    t.integer "in_stock"
    t.integer "out_stock"
    t.integer "stock"
    t.integer "cost_price"
    t.integer "sale_price"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["product_id"], name: "index_product_stocks_on_product_id"
  end

  create_table "product_sub_categories", id: :integer, charset: "utf8mb4", collation: "utf8mb4_unicode_ci", options: "ENGINE=InnoDB ROW_FORMAT=DYNAMIC", force: :cascade do |t|
    t.integer "product_category_id"
    t.string "code"
    t.string "title"
    t.text "comment"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["product_category_id"], name: "index_product_sub_categories_on_product_category_id"
  end

  create_table "product_warranties", charset: "utf8mb4", collation: "utf8mb4_unicode_ci", options: "ENGINE=InnoDB ROW_FORMAT=DYNAMIC", force: :cascade do |t|
    t.bigint "purchase_sale_detail_id"
    t.bigint "product_id"
    t.text "serial"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.boolean "status", default: true
    t.index ["product_id"], name: "index_product_warranties_on_product_id"
    t.index ["purchase_sale_detail_id"], name: "index_product_warranties_on_purchase_sale_detail_id"
  end

  create_table "production_block_types", charset: "utf8mb4", collation: "utf8mb4_unicode_ci", options: "ENGINE=InnoDB ROW_FORMAT=DYNAMIC", force: :cascade do |t|
    t.string "title"
    t.integer "quantity"
    t.integer "status"
    t.text "comment"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "production_blocks", charset: "utf8mb4", collation: "utf8mb4_unicode_ci", options: "ENGINE=InnoDB ROW_FORMAT=DYNAMIC", force: :cascade do |t|
    t.bigint "production_block_type_id"
    t.string "title"
    t.integer "bricks_quantity"
    t.integer "tiles_quantity"
    t.date "date"
    t.integer "status"
    t.text "comment"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.bigint "production_cycle_id"
    t.integer "bhari_production_block_id"
    t.float "jalai_a"
    t.float "jalai_b"
    t.integer "production_status"
    t.bigint "purchase_sale_detail_id"
    t.float "jalai_a_quantity"
    t.float "jalai_b_quantity"
    t.index ["production_block_type_id"], name: "index_production_blocks_on_production_block_type_id"
    t.index ["production_cycle_id"], name: "index_production_blocks_on_production_cycle_id"
    t.index ["purchase_sale_detail_id"], name: "index_production_blocks_on_purchase_sale_detail_id"
  end

  create_table "production_cycles", charset: "utf8mb4", collation: "utf8mb4_unicode_ci", options: "ENGINE=InnoDB ROW_FORMAT=DYNAMIC", force: :cascade do |t|
    t.date "start_date"
    t.date "end_date"
    t.integer "status"
    t.text "comment"
    t.integer "cycle_type"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.bigint "item_id"
    t.float "cost"
    t.float "quantity"
    t.float "total_cost"
    t.float "measurement_quantity"
    t.integer "lines"
    t.float "cost_per_line"
    t.float "per_product_cost"
    t.float "per_thousand_product_cost"
    t.float "item_quantity_per_line"
    t.float "total_item_quantity"
    t.float "per_ton_bricks"
    t.float "total_bricks"
    t.index ["item_id"], name: "index_production_cycles_on_item_id"
  end

  create_table "productions", id: :integer, charset: "utf8mb4", collation: "utf8mb4_unicode_ci", options: "ENGINE=InnoDB ROW_FORMAT=DYNAMIC", force: :cascade do |t|
    t.integer "product_id"
    t.decimal "operation_cost", precision: 10
    t.decimal "cost_price", precision: 10
    t.decimal "sale_price", precision: 10
    t.text "comment"
    t.integer "status"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["product_id"], name: "index_productions_on_product_id"
  end

  create_table "products", id: :integer, charset: "utf8mb4", collation: "utf8mb4_unicode_ci", options: "ENGINE=InnoDB ROW_FORMAT=DYNAMIC", force: :cascade do |t|
    t.integer "item_type_id"
    t.string "code"
    t.string "title"
    t.integer "product_category_id"
    t.integer "product_sub_category_id"
    t.integer "acquire_type"
    t.integer "purchase_type"
    t.integer "purchase_unit"
    t.integer "purchase_factor"
    t.float "cost"
    t.float "sale"
    t.float "minimum"
    t.float "optimal"
    t.float "maximum"
    t.integer "currency"
    t.text "comment"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.float "stock", default: 0.0
    t.string "location"
    t.string "size_1", default: "0"
    t.string "size_2", default: "0"
    t.string "size_3", default: "0"
    t.string "size_4", default: "0"
    t.string "size_5", default: "0"
    t.string "size_6", default: "0"
    t.string "size_7", default: "0"
    t.string "size_8", default: "0"
    t.string "size_9", default: "0"
    t.string "size_10", default: "0"
    t.string "size_11", default: "0"
    t.string "size_12", default: "0"
    t.string "size_13", default: "0"
    t.integer "product_type", default: 0
    t.float "measurement_quantity"
    t.bigint "raw_product_id"
    t.float "gst", default: 0.0
    t.float "vat", default: 0.0
    t.float "hst", default: 0.0
    t.float "pst", default: 0.0
    t.float "qst", default: 0.0
    t.boolean "with_serial"
    t.text "warranty_list"
    t.float "marla"
    t.float "square_feet"
    t.index ["item_type_id"], name: "index_products_on_item_type_id"
    t.index ["product_category_id"], name: "index_products_on_product_category_id"
    t.index ["product_sub_category_id"], name: "index_products_on_product_sub_category_id"
    t.index ["raw_product_id"], name: "index_products_on_raw_product_id"
  end

  create_table "property_installments", charset: "utf8mb4", collation: "utf8mb4_unicode_ci", options: "ENGINE=InnoDB ROW_FORMAT=DYNAMIC", force: :cascade do |t|
    t.bigint "property_plan_id"
    t.integer "installment_no"
    t.decimal "installment_price", precision: 15, scale: 2
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.datetime "due_date"
    t.integer "due_status"
    t.float "high_price"
    t.float "normal_price"
    t.text "bank_detail"
    t.integer "payment_method"
    t.text "payment_detail"
    t.index ["property_plan_id"], name: "index_property_installments_on_property_plan_id"
  end

  create_table "property_plans", charset: "utf8mb4", collation: "utf8mb4_unicode_ci", options: "ENGINE=InnoDB ROW_FORMAT=DYNAMIC", force: :cascade do |t|
    t.integer "property_type"
    t.decimal "area_in_marla", precision: 7, scale: 2
    t.decimal "price_per_marla", precision: 15, scale: 2
    t.decimal "total_price", precision: 15, scale: 2
    t.integer "payment_type"
    t.integer "payment_plan"
    t.integer "no_of_installments"
    t.decimal "advance", precision: 15, scale: 2
    t.integer "high_amount_installments"
    t.decimal "total_high_amount", precision: 15, scale: 2
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.bigint "order_id"
    t.decimal "last_instalment", precision: 15, scale: 5, default: "0.0"
    t.datetime "due_date"
    t.integer "due_status"
    t.text "bank_detail"
    t.integer "payment_method"
    t.text "payment_detail"
    t.datetime "deleted_at"
    t.index ["deleted_at"], name: "index_property_plans_on_deleted_at"
    t.index ["order_id"], name: "index_property_plans_on_order_id"
  end

  create_table "purchase_sale_details", id: :integer, charset: "utf8mb4", collation: "utf8mb4_unicode_ci", options: "ENGINE=InnoDB ROW_FORMAT=DYNAMIC", force: :cascade do |t|
    t.integer "sys_user_id"
    t.integer "transaction_type"
    t.float "total_bill"
    t.float "amount"
    t.float "discount_price"
    t.integer "status"
    t.text "comment"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "voucher_id"
    t.integer "account_id"
    t.float "carriage", default: 0.0
    t.float "loading", default: 0.0
    t.bigint "order_id"
    t.bigint "staff_id"
    t.string "bill_no"
    t.string "user_name"
    t.string "destination"
    t.string "l_c"
    t.string "g_d"
    t.string "g_d_type"
    t.datetime "g_d_date"
    t.string "quantity"
    t.string "dispatched_to"
    t.datetime "despatch_date"
    t.string "job_no"
    t.string "reference_no"
    t.string "company_name"
    t.integer "with_gst"
    t.text "bank_detail"
    t.integer "payment_method"
    t.text "payment_detail"
    t.datetime "deleted_at"
    t.index ["account_id"], name: "index_purchase_sale_details_on_account_id"
    t.index ["deleted_at"], name: "index_purchase_sale_details_on_deleted_at"
    t.index ["order_id"], name: "index_purchase_sale_details_on_order_id"
    t.index ["staff_id"], name: "index_purchase_sale_details_on_staff_id"
    t.index ["sys_user_id"], name: "index_purchase_sale_details_on_sys_user_id"
  end

  create_table "purchase_sale_items", id: :integer, charset: "utf8mb4", collation: "utf8mb4_unicode_ci", options: "ENGINE=InnoDB ROW_FORMAT=DYNAMIC", force: :cascade do |t|
    t.integer "purchase_sale_detail_id"
    t.integer "item_id"
    t.float "quantity"
    t.float "cost_price"
    t.float "sale_price"
    t.float "total_cost_price"
    t.float "total_sale_price"
    t.integer "status"
    t.text "comment"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "product_id"
    t.integer "transaction_type"
    t.string "size_1", default: "0"
    t.string "size_2", default: "0"
    t.string "size_3", default: "0"
    t.string "size_4", default: "0"
    t.string "size_5", default: "0"
    t.string "size_6", default: "0"
    t.string "size_7", default: "0"
    t.string "size_8", default: "0"
    t.string "size_9", default: "0"
    t.string "size_10", default: "0"
    t.string "size_11", default: "0"
    t.string "size_12", default: "0"
    t.string "size_13", default: "0"
    t.float "discount_price", default: 0.0
    t.integer "purchase_sale_type", default: 0
    t.datetime "expiry_date"
    t.float "remaining_quantity"
    t.float "extra_expence"
    t.float "extra_quantity"
    t.decimal "gst", precision: 15, scale: 2
    t.decimal "gst_amount", precision: 15, scale: 2
    t.datetime "deleted_at"
    t.index ["deleted_at"], name: "index_purchase_sale_items_on_deleted_at"
    t.index ["item_id"], name: "index_purchase_sale_items_on_item_id"
    t.index ["product_id"], name: "index_purchase_sale_items_on_product_id"
    t.index ["purchase_sale_detail_id"], name: "index_purchase_sale_items_on_purchase_sale_detail_id"
  end

  create_table "raw_products", charset: "utf8mb4", collation: "utf8mb4_unicode_ci", options: "ENGINE=InnoDB ROW_FORMAT=DYNAMIC", force: :cascade do |t|
    t.string "code"
    t.string "title"
    t.float "stock"
    t.integer "acquire_type"
    t.float "cost"
    t.float "sale"
    t.float "minimum"
    t.float "optimal"
    t.float "maximum"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "first_stock", default: 0
    t.integer "second_stock", default: 0
    t.integer "third_stock", default: 0
    t.integer "nakasi_stock", default: 0
  end

  create_table "remarks", charset: "utf8mb4", collation: "utf8mb4_unicode_ci", force: :cascade do |t|
    t.integer "user"
    t.text "body"
    t.text "message"
    t.text "comment"
    t.string "remark_type"
    t.string "remarkable_type", null: false
    t.bigint "remarkable_id", null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["remarkable_type", "remarkable_id"], name: "index_remarks_on_remarkable"
  end

  create_table "salaries", id: :integer, charset: "utf8mb4", collation: "utf8mb4_unicode_ci", options: "ENGINE=InnoDB ROW_FORMAT=DYNAMIC", force: :cascade do |t|
    t.integer "paid_salary"
    t.integer "advance", default: 0
    t.integer "leaves_in_month", default: 0
    t.integer "staff_id"
    t.integer "paid_to"
    t.integer "payment_type", default: 0
    t.integer "advance_amount", default: 0
    t.integer "advance_due_till_this_transaction", default: 0
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "account_id"
    t.text "comment"
    t.float "balance"
    t.float "total_balance"
    t.index ["account_id"], name: "index_salaries_on_account_id"
    t.index ["staff_id"], name: "index_salaries_on_staff_id"
  end

  create_table "salary_detail_product_quantities", charset: "utf8mb4", collation: "utf8mb4_unicode_ci", options: "ENGINE=InnoDB ROW_FORMAT=DYNAMIC", force: :cascade do |t|
    t.bigint "salary_detail_id"
    t.bigint "staff_id"
    t.bigint "product_id"
    t.float "quantity"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["product_id"], name: "index_salary_detail_product_quantities_on_product_id"
    t.index ["salary_detail_id"], name: "index_salary_detail_product_quantities_on_salary_detail_id"
    t.index ["staff_id"], name: "index_salary_detail_product_quantities_on_staff_id"
  end

  create_table "salary_details", id: :integer, charset: "utf8mb4", collation: "utf8mb4_unicode_ci", options: "ENGINE=InnoDB ROW_FORMAT=DYNAMIC", force: :cascade do |t|
    t.integer "staff_id"
    t.float "wage_rate"
    t.float "quantity"
    t.float "amount"
    t.text "remarks"
    t.text "comment"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "product_id"
    t.integer "status"
    t.integer "extra"
    t.bigint "daily_book_id"
    t.bigint "raw_product_id"
    t.float "raw_quantity"
    t.float "raw_wage_rate"
    t.float "gift_rate"
    t.float "coverge_rate"
    t.float "wage_debit"
    t.float "gift_pay"
    t.float "coverge_pay"
    t.integer "staff_pathera_id"
    t.integer "transaction_location"
    t.integer "khakar_quanity"
    t.integer "khakar_remaning"
    t.integer "khakar_debit"
    t.integer "khakar_wast"
    t.integer "khakar_extra"
    t.integer "khakar_credit"
    t.integer "pather_remaning_quanity"
    t.integer "pather_salary_detail_id"
    t.bigint "purchase_sale_detail_id"
    t.integer "pather_khakar_wast"
    t.float "balance"
    t.float "total_balance"
    t.index ["daily_book_id"], name: "index_salary_details_on_daily_book_id"
    t.index ["product_id"], name: "index_salary_details_on_product_id"
    t.index ["purchase_sale_detail_id"], name: "index_salary_details_on_purchase_sale_detail_id"
    t.index ["raw_product_id"], name: "index_salary_details_on_raw_product_id"
    t.index ["staff_id"], name: "index_salary_details_on_staff_id"
  end

  create_table "sms_logs", charset: "utf8mb4", collation: "utf8mb4_unicode_ci", options: "ENGINE=InnoDB ROW_FORMAT=DYNAMIC", force: :cascade do |t|
    t.string "sms_from"
    t.text "sms_to"
    t.text "msg"
    t.text "sms_by"
    t.text "response"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "staff_deals", charset: "utf8mb4", collation: "utf8mb4_unicode_ci", options: "ENGINE=InnoDB ROW_FORMAT=DYNAMIC", force: :cascade do |t|
    t.bigint "staff_id"
    t.bigint "product_id"
    t.decimal "cost", precision: 10
    t.text "comment"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["product_id"], name: "index_staff_deals_on_product_id"
    t.index ["staff_id"], name: "index_staff_deals_on_staff_id"
  end

  create_table "staff_ledger_books", charset: "utf8mb4", collation: "utf8mb4_unicode_ci", options: "ENGINE=InnoDB ROW_FORMAT=DYNAMIC", force: :cascade do |t|
    t.bigint "staff_id"
    t.bigint "salary_id"
    t.bigint "salary_detail_id"
    t.decimal "debit", precision: 15, scale: 5
    t.decimal "credit", precision: 15, scale: 5
    t.decimal "balance", precision: 15, scale: 5
    t.text "comment"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "status"
    t.text "bank_detail"
    t.integer "payment_method"
    t.text "payment_detail"
    t.index ["salary_detail_id"], name: "index_staff_ledger_books_on_salary_detail_id"
    t.index ["salary_id"], name: "index_staff_ledger_books_on_salary_id"
    t.index ["staff_id"], name: "index_staff_ledger_books_on_staff_id"
  end

  create_table "staff_raw_products", charset: "utf8mb4", collation: "utf8mb4_unicode_ci", options: "ENGINE=InnoDB ROW_FORMAT=DYNAMIC", force: :cascade do |t|
    t.bigint "staff_id"
    t.bigint "raw_product_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["raw_product_id"], name: "index_staff_raw_products_on_raw_product_id"
    t.index ["staff_id"], name: "index_staff_raw_products_on_staff_id"
  end

  create_table "staffs", id: :integer, charset: "utf8mb4", collation: "utf8mb4_unicode_ci", options: "ENGINE=InnoDB ROW_FORMAT=DYNAMIC", force: :cascade do |t|
    t.string "name"
    t.string "father"
    t.string "education"
    t.string "phone"
    t.string "address"
    t.string "cnic"
    t.date "date_of_joining"
    t.integer "yearly_increment"
    t.decimal "monthly_salary", precision: 15, scale: 5
    t.string "staff_department"
    t.integer "gender"
    t.decimal "advance_amount", precision: 15, scale: 5, default: "0.0"
    t.boolean "terminated", default: false
    t.datetime "terminated_at", default: -> { "CURRENT_TIMESTAMP" }
    t.boolean "deleted", default: false
    t.datetime "deleted_at", default: -> { "CURRENT_TIMESTAMP" }
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.decimal "wage_rate", precision: 15, scale: 5, default: "0.0"
    t.text "comment"
    t.decimal "balance", precision: 15, scale: 5, default: "0.0"
    t.bigint "department_id"
    t.string "code"
    t.integer "staff_type"
    t.decimal "wage_debit", precision: 15, scale: 5
    t.float "raw_product_quantity", default: 0.0
    t.float "raw_product_quantity_tile", default: 0.0
    t.index ["department_id"], name: "index_staffs_on_department_id"
  end

  create_table "sys_users", id: :integer, charset: "utf8mb4", collation: "utf8mb4_unicode_ci", options: "ENGINE=InnoDB ROW_FORMAT=DYNAMIC", force: :cascade do |t|
    t.string "code"
    t.string "cnic"
    t.string "name"
    t.integer "user_type_id"
    t.integer "user_group"
    t.integer "status"
    t.string "occupation"
    t.integer "credit_status"
    t.decimal "credit_limit", precision: 15, scale: 2
    t.decimal "opening_balance", precision: 15, scale: 2
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.decimal "balance", precision: 15, scale: 2
    t.text "gst"
    t.text "ntn"
    t.string "father"
    t.string "nom_name"
    t.string "nom_father"
    t.string "nom_cnic"
    t.string "nom_relation"
    t.index ["user_type_id"], name: "index_sys_users_on_user_type_id"
  end

  create_table "user_abilities", id: :integer, charset: "utf8mb4", collation: "utf8mb4_unicode_ci", options: "ENGINE=InnoDB ROW_FORMAT=DYNAMIC", force: :cascade do |t|
    t.integer "roles_mask"
    t.integer "user_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["user_id"], name: "index_user_abilities_on_user_id"
  end

  create_table "user_types", id: :integer, charset: "utf8mb4", collation: "utf8mb4_unicode_ci", options: "ENGINE=InnoDB ROW_FORMAT=DYNAMIC", force: :cascade do |t|
    t.string "title"
    t.string "code"
    t.float "discount_by_percentage"
    t.float "discount_by_amount"
    t.text "comment"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "users", id: :integer, charset: "utf8mb4", collation: "utf8mb4_unicode_ci", options: "ENGINE=InnoDB ROW_FORMAT=DYNAMIC", force: :cascade do |t|
    t.string "email", null: false
    t.string "encrypted_password", null: false
    t.string "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer "sign_in_count", default: 0, null: false
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.integer "failed_attempts", default: 0, null: false
    t.string "unlock_token"
    t.datetime "locked_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "roles_mask"
    t.string "name"
    t.string "user_name"
    t.string "father_name"
    t.string "city"
    t.string "phone"
    t.string "fax"
    t.text "address"
    t.integer "created_by_id"
    t.string "company_type"
    t.text "email_to"
    t.text "email_cc"
    t.text "email_bcc"
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true
    t.index ["user_name"], name: "index_users_on_user_name", unique: true
  end

  create_table "versions", charset: "utf8mb4", collation: "utf8mb4_unicode_ci", options: "ENGINE=InnoDB ROW_FORMAT=DYNAMIC", force: :cascade do |t|
    t.string "item_type", limit: 191, null: false
    t.bigint "item_id", null: false
    t.string "event", null: false
    t.string "whodunnit"
    t.text "object", size: :long
    t.datetime "created_at"
    t.text "object_changes"
    t.index ["item_type", "item_id"], name: "index_versions_on_item_type_and_item_id"
  end

  create_table "warranties", charset: "utf8mb4", collation: "utf8mb4_unicode_ci", options: "ENGINE=InnoDB ROW_FORMAT=DYNAMIC", force: :cascade do |t|
    t.text "serial_number"
    t.text "comment"
    t.bigint "product_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["product_id"], name: "index_warranties_on_product_id"
  end

  add_foreign_key "active_storage_attachments", "active_storage_blobs", column: "blob_id"
  add_foreign_key "expenses", "accounts"
  add_foreign_key "expenses", "expense_types"
  add_foreign_key "investments", "accounts"
  add_foreign_key "items", "item_types"
  add_foreign_key "ledger_books", "sys_users"
  add_foreign_key "materials", "items"
  add_foreign_key "materials", "productions"
  add_foreign_key "materials", "products"
  add_foreign_key "product_sub_categories", "product_categories"
  add_foreign_key "production_blocks", "production_block_types"
  add_foreign_key "productions", "products"
  add_foreign_key "property_installments", "property_plans"
  add_foreign_key "purchase_sale_details", "accounts"
  add_foreign_key "purchase_sale_details", "sys_users"
  add_foreign_key "purchase_sale_items", "items"
  add_foreign_key "purchase_sale_items", "products"
  add_foreign_key "purchase_sale_items", "purchase_sale_details"
  add_foreign_key "salaries", "accounts"
  add_foreign_key "salaries", "staffs"
  add_foreign_key "sys_users", "user_types"
  add_foreign_key "user_abilities", "users"
end
