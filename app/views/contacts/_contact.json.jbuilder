json.extract! contact, :id, :country_id, :city_id, :address, :home, :office, :Mobile, :fax, :email, :comment, :status, :created_at, :updated_at
json.url contact_url(contact, format: :json)
