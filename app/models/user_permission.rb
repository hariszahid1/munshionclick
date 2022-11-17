class UserPermission < ApplicationRecord
	establish_connection "#{Rails.env}".to_sym
	belongs_to :user
end
