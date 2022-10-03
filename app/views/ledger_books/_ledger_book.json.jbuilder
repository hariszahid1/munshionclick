json.extract! ledger_book, :id, :sys_user, :debit, :credit, :comment, :created_at, :updated_at
json.url ledger_book_url(ledger_book, format: :json)
