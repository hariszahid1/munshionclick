class AddIsUserPermissionToUser < ActiveRecord::Migration[6.1]
		def change
			add_column :users, :permission_updated,  :boolean, default:false
		end	
end
