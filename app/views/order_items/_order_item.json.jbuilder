json.extract! order_item, :id, :order_id, :product_id, :item_id, :quantity, :cost_price, :sale_price, :total_cost_price, :total_sale_price, :status, :comment, :transaction_type, :discount_price, :purchase_sale_type, :expiry_date, :created_at, :updated_at
json.url order_item_url(order_item, format: :json)
