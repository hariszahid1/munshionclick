json.extract! expense_type, :id, :title, :comment, :created_at, :updated_at
json.url expense_type_url(expense_type, format: :json)
