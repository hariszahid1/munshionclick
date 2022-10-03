json.extract! product_stock, :id, :product_id, :in_stock, :out_stock, :stock, :created_at, :updated_at
json.url product_stock_url(product_stock, format: :json)
