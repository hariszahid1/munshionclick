module SalaryDetailsCsvMethods
  extend ActiveSupport::Concern

	def get_data_for_salary_details_csv(data)
		temp=[]

		if current_user.superAdmin.company_type=="batamega"
			# <%= render partial: "create_bata", locals: {purchase_sale_detail: @purchase_sale_detail} %>
		elsif current_user.superAdmin.company_type=="mianji"
			# <%= render partial: "create_fc", locals: {purchase_sale_detail: @purchase_sale_detail} %>
		else
			@time = Time.zone.now
			data.each do |salary_detail| 
				if salary_detail.product.present? 
					if ((salary_detail.quantity.to_f*salary_detail.status.to_f) != 0 and salary_detail.amount != 0)
						first= salary_detail.id
						second= salary_detail.staff.name 
						third=salary_detail.product.present? ? salary_detail.product.title : "" 
						fourth=salary_detail.quantity 
						fifth=salary_detail.amount 
						sixth=salary_detail.remarks.to_f.round(2) 
						seventh=salary_detail.created_at.strftime("%d-%b-%Y") 
						temp.push([first,second,third,fourth,fifth,sixth,seventh])
					elsif ( (salary_detail.quantity.to_f*salary_detail.status.to_f) == 0 and salary_detail.amount == 0)
						first=salary_detail.id
						second=salary_detail.staff.name
						third="Day OFF"
						fourth="Day OFF"
						fifth="Day OFF"
						sixth="Day OFF"
						seventh=salary_detail.created_at.strftime("%d-%b-%Y")
						temp.push([first,second,third,fourth,fifth,sixth,seventh])
					end
				elsif (salary_detail.amount != 0 || salary_detail.khakar_credit != 0) && salary_detail.quantity.to_f>0
						first=salary_detail.id 
						second=salary_detail.staff.name 
						third=salary_detail.wage_rate.present? ? salary_detail.wage_rate : "" 
						fourth=salary_detail.quantity 
						fifth="#{salary_detail.amount}  #{salary_detail.khakar_credit}"
						sixth=salary_detail.remarks.to_f.round(2) 
						seventh=salary_detail.created_at.strftime("%d-%b-%Y")
						temp.push([first,second,third,fourth,fifth,sixth,seventh])
				elsif ( (salary_detail.quantity.to_f*salary_detail.status.to_f) == 0 and salary_detail.amount == 0)
					first = salary_detail.id 
					second = salary_detail.staff.name 
					third = "Day OFF"
					fourth = "Day OFF"
					fifth = "Day OFF"
					sixth = "Day OFF"
					seventh = salary_detail.created_at.strftime("%d-%b-%Y") 
					temp.push([first,second,third,fourth,fifth,sixth,seventh])
				end
			end 
			temp.push(["total","","","",@salary_details.sum(:amount),""])
		end
	end

end

