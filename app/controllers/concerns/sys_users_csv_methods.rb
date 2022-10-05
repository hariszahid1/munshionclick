# frozen_string_literal: true

# CSV Methods
module SysUsersCsvMethods
  extend ActiveSupport::Concern

	def user_csv
		CSV.generate do |csv|
			csv.add_row ['Code', 'Name','User group','Status','Ocupation','Opening blance','balance','jama/benam','address']
			
			@sys_users.each do |sys_user|
				temp=''
				if (sys_user.balance.to_f > 0 )
					temp="Jama"
				elsif (sys_user.balance.to_f < 0 )
					temp="Benam"
				else
					temp=''
				end
				csv.add_row ["#{sys_user.code}","#{sys_user.name}","#{sys_user.user_group}","#{sys_user.status}","#{sys_user.occupation}","#{sys_user.opening_balance.to_f.round(2)}","#{sys_user.balance.to_f.round(2)}","#{temp}","#{sys_user.contact.city.title}"]
			end
		end
	end

end
