module ApplicationHelper
  def rescued_csrf_meta_tags
    csrf_meta_tags
  rescue ArgumentError
    request.reset_session
    csrf_meta_tags
  end
  def self.asset_data_base64(path)
    asset = Rails.application.assets.find_asset(path)
    throw "Could not find asset '#{path}'" if asset.nil?
    base64 = Base64.encode64(asset.to_s).gsub(/\s+/, "")
    "data:#{asset.content_type};base64,#{Rack::Utils.escape(base64)}"
  end

	def self.check_can_create(user,temp_module)
		return user.user_permissions.find_by(module: temp_module).can_create
	end
	def self.check_can_read(user,temp_module)
		return user.user_permissions.find_by(module: temp_module ).can_read
	end
	def self.check_can_update(user,temp_module)
		return user.user_permissions.find_by(module: temp_module).can_update
	end
	def self.check_can_delete(user,temp_module)
		return user.user_permissions.find_by(module: temp_module).can_delete
	end
	def self.check_can_download_csv(user,temp_module)
		return user.user_permissions.find_by(module: temp_module).can_download_csv
	end
	def self.check_can_download_pdf(user,temp_module)
		return user.user_permissions.find_by(module: temp_module).can_download_pdf
	end
	def self.check_can_accessed(user,temp_module)
		return user.user_permissions.find_by(module: temp_module).can_accessed
	end
	def self.check_is_hidden(user,temp_module)
		return user.user_permissions.find_by(module: temp_module).is_hidden
	end
	def self.check_can_import_export(user,temp_module)
		return user.user_permissions.find_by(module: temp_module).can_import_export
	end	
	def self.check_can_send_email(user,temp_module)
		return user.user_permissions.find_by(module: temp_module).can_import_export
	end	
end
