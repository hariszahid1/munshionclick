json.extract! expense, :id, :expense_type, :expense, :comment, :school_branch_id, :created_at, :updated_at
json.url expense_url(expense, format: :json)
