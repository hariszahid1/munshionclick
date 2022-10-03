json.extract! daily_book, :id, :book_date, :total_paid, :total_remaining, :department_id, :created_at, :updated_at
json.url daily_book_url(daily_book, format: :json)
