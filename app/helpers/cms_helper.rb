# frozen_string_literal: true

# CMS Helper
module CmsHelper
	def get_data_for_cms_csv
		temp=[]
		@sys_user.each do |sys_user|
			data1 = sys_user['code']
			data2 = sys_user['cnic']
			data3 = sys_user['name']
			data4 = sys_user['user_type_id']
			data5 = sys_user['user_group']
			data6 = sys_user['status']
			data7 = sys_user['occupation']
			data8 = sys_user['credit_limit']
			data9 = sys_user['gst']
			data10 = sys_user['ntn']
			data11 = sys_user[:contact]['city_id']
			data12 = sys_user[:contact]['country_id']
			temp.push([data1, data2, data3, data4, data5, data6, data7,
				data8, data9, data10, data11, data12,
				])
		end
		return temp
	end
end
