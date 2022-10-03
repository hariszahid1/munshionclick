json.extract! salary_detail, :id, :staff_id, :amount, :remarks, :comment, :created_at, :updated_at
json.url salary_detail_url(salary_detail, format: :json)
