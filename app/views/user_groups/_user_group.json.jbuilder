json.extract! user_group, :id, :title, :comment, :created_at, :updated_at
json.url user_group_url(user_group, format: :json)
