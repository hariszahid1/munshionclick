json.extract! loan, :id, :debit,:credit ,:comment, :created_at, :updated_at
json.url investment_url(loans, format: :json)
