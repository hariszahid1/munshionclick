json.extract! remark, :id, :user, :body, :message, :comment, :remark_type, :remarkable_id, :remarkable_type, :created_at, :updated_at
json.url remark_url(remark, format: :json)
