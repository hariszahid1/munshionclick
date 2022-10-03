json.extract! sys_user, :id, :code, :cnic, :name, :user_type_id, :user_group, :contact_id, :status, :occupation, :credit_status, :credit_limit, :opening_balance, :created_at, :updated_at
json.url sys_user_url(sys_user, format: :json)
