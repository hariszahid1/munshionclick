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
			data8 = sys_user['credit_status']
			data9 = sys_user['credit_limit']
			data10 = sys_user['opening_balance']
			data11 = sys_user['balance']
			data12 = sys_user['gst']
			data13 = sys_user['ntn']
			data18 = sys_user['father']
			data14 = sys_user['nom_name']
			data15 = sys_user['nom_father']
			data16 = sys_user['nom_cnic']
			data17 = sys_user['nom_relation']
			data19 = sys_user[:contact]['address']
			data20 = sys_user[:contact]['home']
			data21 = sys_user[:contact]['office']
			data22 = sys_user[:contact]['mobile']
			data23 = sys_user[:contact]['fax']
			data24 = sys_user[:contact]['email']
			data25 = sys_user[:contact]['comment']
			data26 = sys_user[:contact]['status']
			data27 = sys_user[:contact]['city_id']
			data28 = sys_user[:contact]['country_id']
			data29 = sys_user[:contact]['permanent_Address']
			temp.push([data1, data2, data3, data4, data5, data6, data7, data8, data9, data10,
				        		data11, data12, data13, data14, data15, data16, data17, data18, data19, data20,
										data21, data22, data23, data24, data25, data26, data27, data28, data29
				])
		end
		return temp
	end
end
