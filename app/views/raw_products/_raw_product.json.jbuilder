json.extract! raw_product, :id, :code, :title, :stock, :acquire_type, :cost, :sale, :minimum, :optimal, :maximum, :created_at, :updated_at
json.url raw_product_url(raw_product, format: :json)
