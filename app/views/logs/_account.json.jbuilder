json.extract! account, :id, :title, :bank_name, :iban_number, :amount, :created_at, :updated_at
json.url account_url(account, format: :json)
