json.extract! item, :id, :item_type_id, :title, :code, :minimum, :optimal, :maximun, :comment, :status, :created_at, :updated_at
json.url item_url(item, format: :json)
