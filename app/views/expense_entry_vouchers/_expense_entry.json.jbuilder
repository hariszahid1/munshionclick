json.extract! expense_entry_voucher, :id, :amount, :expense_voucher_id, :expense_type_id, :comment, :status, :created_at, :updated_at
json.url expense_entry_voucher_url(expense_entry_voucher, format: :json)
