json.extract! expense_entry, :id, :amount, :expense_id, :expense_type_id, :account_id, :comment, :status, :created_at, :updated_at
json.url expense_entry_url(expense_entry, format: :json)
