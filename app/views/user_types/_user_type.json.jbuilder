json.extract! user_type, :id, :title, :code, :discount_by_percentage, :discount_by_amount, :comment, :created_at, :updated_at
json.url user_type_url(user_type, format: :json)
