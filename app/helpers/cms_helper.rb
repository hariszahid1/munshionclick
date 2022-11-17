# frozen_string_literal: true

# CMS Helper
module CmsHelper
	def get_data_for_cms_csv
		temp=[]
		@sys_user.each do |sys_user|
			if sys_user.cms_data.present?
				data1 = sys_user.cms_data.try(:[], 'client_number')
				data2 = sys_user.cms_data.try(:[], 'client_name')
				data3 = sys_user.cms_data.try(:[], 'project_name')
				data4 = sys_user.cms_data.try(:[], 'client_type')
				data5 = sys_user.cms_data.try(:[], 'client_status')
				data6 = sys_user.cms_data.try(:[], 'category')
				data7 = sys_user.cms_data.try(:[], 'deal_status')
				data8 = sys_user.cms_data.try(:[], 'source')
				data9 = sys_user.cms_data.try(:[], 'plot_size')
				data10 = sys_user.cms_data.try(:[], 'short_details')
				data11 = sys_user.created_at
				data12 = sys_user&.contact&.city&.title
				data13 = sys_user&.contact&.country&.title
				temp.push([data1, data2, data3, data4, data5, data6, data7,
					data8, data9, data10, data11, data12, data13
					])
			end
		end
		return temp
	end
end
