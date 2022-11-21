# frozen_string_literal: true

# CMS Helper
module CmsHelper
	def get_data_for_cms_csv
		temp=[]
		@sys_user.each do |sys_user|
			if sys_user.cms_data.present?
				data1 = sys_user.code
				data2 = sys_user.name
				data3 = sys_user.credit_status
				data4 = sys_user.cms_data.try(:[], 'project_name')
				data5 = sys_user.cms_data.try(:[], 'client_type')
				data6 = sys_user.cms_data.try(:[], 'client_status')
				data7 = sys_user.cms_data.try(:[], 'category')
				data8 = sys_user.cms_data.try(:[], 'deal_status')
				data9 = sys_user.cms_data.try(:[], 'source')
				data10 = sys_user.ntn
				data11 = sys_user.gst
				data12 = sys_user.created_at
				data13 = sys_user&.contact&.city&.title
				data14 = sys_user&.contact&.country&.title
				temp.push([data1, data2, data3, data4, data5, data6, data7,
					data8, data9, data10, data11, data12, data13, data14
					])
			end
		end
		return temp
	end

	def sorted_data
    @sorted_data = []
    @q.result.each do |d|
      @sorted_data << {
                        id: d.id,
                        name: d.name,
                        number: d.code,
												agent_id: d.credit_status,
												short_details: d.gst,
												plot_size: d.ntn,
                        cms_data: d.cms_data,
												created_at: d.created_at.strftime("%d-%m-%y-%H:%M"),
                        city: d.contact&.city&.title,
                        country: d.contact&.country&.title
                       }
    end
  end
end
