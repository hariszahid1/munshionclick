json.extract! purchase_sale_detail, :id, :user_id_id, :transaction_type, :total_bill, :amount, :discount_price, :status, :comment, :created_at, :updated_at
json.url purchase_sale_detail_url(purchase_sale_detail, format: :json)
