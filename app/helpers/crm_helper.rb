# frozen_string_literal: true

# CRM Helper
module CrmHelper
	def get_data_for_crm_csv
		temp=[]
		@sys_user.each do |sys_user|
			if sys_user.cms_data.present?
				data1 = sys_user.name
				data2 = User.find_by(id: sys_user.credit_status)&.name
				data3 = sys_user.cms_data.try(:[], 'project_name')
				data4 = sys_user.cms_data.try(:[], 'category')
				data5 = sys_user.ntn
				data6 = sys_user.gst
				data7 = sys_user.created_at&.strftime('%d-%m-%Y')
				temp.push([data1, data2, data3, data4, data5, data6, data7
					])
			end
		end
		return temp
	end

	def sorted_data
    @sorted_data = []
    @q.result.each do |d|
      @sorted_data << {
                        name: d.name,
												agent_name: User.find_by(id: d.credit_status)&.name,
												short_details: d.gst,
												plot_size: d.ntn,
                        cms_data: d.cms_data,
												created_at: d.created_at.strftime("%d-%m-%y-%H:%M"),
                       }
    end
  end

	def get_data_for_crm_export
		temp = []
		@sys_user.each do |sys_user|
			if sys_user.cms_data.present?
				data1 = sys_user.id
				data2 = sys_user.occupation
				data3 = sys_user.name
				data4 = sys_user.credit_status
				data5 = sys_user.gst
				data6 = sys_user.ntn
				data7 = sys_user.cms_data.try(:[], 'project_name')
				data8 = sys_user.cms_data.try(:[], 'client_type')
				data9 = sys_user.cms_data.try(:[], 'client_status')
				data10 = sys_user.cms_data.try(:[], 'category')
				data11 = sys_user.cms_data.try(:[], 'deal_status')
				data12 = sys_user.cms_data.try(:[], 'source')
				temp.push([data1, data2, data3, data4, data5, data6, data7, data8, data9, data10,
					data11, data12
					])
					byebug
			end
		end
		return temp
	end
end
