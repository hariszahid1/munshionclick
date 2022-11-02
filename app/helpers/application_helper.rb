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

	def self.current_user_permissions(user,temp_module,action)
		if action == "can_create"
		 result = user.user_permissions.where(module: temp_module).first.can_create
		elsif action == "can_read"
			result = user.user_permissions.where(module: temp_module ).first.can_read
		elsif action == "can_update"
			result = user.user_permissions.where(module: temp_module ).first.can_update
		elsif action == "can_delete"
			result = user.user_permissions.where(module: temp_module ).first.can_delete
		elsif action== "is_hidden"
			result = user.user_permissions.where(module: temp_module ).first.is_hidden
		elsif action== "can_download_pdf"
			result = user.user_permissions.where(module: temp_module ).first.can_download_pdf
		elsif action== "can_download_csv;"
			result = user.user_permissions.where(module: temp_module ).first.can_download_csv
		elsif action== "can_send_email"
			result = user.user_permissions.where(module: temp_module ).first.can_send_email
		elsif action== "can_import_export"
			result = user.user_permissions.where(module: temp_module ).first.can_import_export
		else
			result = user.user_permissions.where(module: temp_module ).first.can_accessed
		end
		return result
		# ApplicationHelper.current_user_permissions(current_user,"accounts","can_update")
	end
end
