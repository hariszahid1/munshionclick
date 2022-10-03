json.extract! order, :id, :sys_user_id, :transaction_type, :total_bill, :amount, :discount_price, :status, :comment, :voucher_id, :account_id, :carriage, :loading, :created_at, :updated_at
json.url order_url(order, format: :json)
